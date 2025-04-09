extends Node2D

var bounces := 10  # 激光反弹次数限制
const MAX_LENGTH := 1000000  # 激光的最大长度（射程）

signal receive_area_detected

@onready var line = $Line2D  # 用于绘制激光路径
var max_cast_to  # 最大射程向量，固定为 Y 轴正方向
var lasers := []  # 存储所有 RayCast2D 节点

func _ready():
	self.global_position = get_node("..").global_position
	# 初始化激光射线
	lasers.append($Laser)
	for i in range(bounces):
		var raycast = $Laser.duplicate()
		raycast.enabled = false
		add_child(raycast)
		lasers.append(raycast)
	
	update_laser_direction()

func update_laser_direction():
	max_cast_to = Vector2(0, MAX_LENGTH)
	for raycast in lasers:
		raycast.target_position = max_cast_to

func _process(_delta):
	$End.emitting = true
	line.clear_points()
	line.add_point(Vector2.ZERO)
	max_cast_to = Vector2(0, MAX_LENGTH)

	var idx = -1
	for raycast in lasers:
		idx += 1
		var collision_point = raycast.get_collision_point()
		raycast.target_position = max_cast_to

		if raycast.is_colliding():
			line.add_point(collision_point - global_position)
			var collider = raycast.get_collider()

			var is_reflect = false
			var is_block = false

			# 优先处理镜子区域的检测
			if collider is Area2D:
				match collider.name:
					"ReflectArea":
						is_reflect = true
					"BlockArea":
						is_block = true
						# 触发信号
					"ReceiveArea":
						emit_signal("receive_area_detected")
			elif collider is TileMap:
				var tilemap = collider
				var local_pos = tilemap.to_local(collision_point)
				var coords = tilemap.local_to_map(local_pos)
				var tile_data = tilemap.get_cell_tile_data(0, coords)  # layer 0
				if tile_data:
					# 这里只判断墙壁和玩家阻挡，不作为反射镜使用
					var tile_type = tile_data.get_custom_data("type")
					match tile_type:
						"wall", "player_block":
							is_block = true
			else:
				# 针对其他对象，通过碰撞层判断
				var layer = collider.collision_layer
				if layer & (1 << 0) or layer & (1 << 4):  # 第1层 Player，第5层 Wall
					is_block = true
			
			if is_reflect:
				max_cast_to = max_cast_to.bounce(raycast.get_collision_normal())
				if idx < lasers.size() - 1:
					lasers[idx + 1].enabled = true
					lasers[idx + 1].global_position = collision_point + (max_cast_to.normalized() * 1)
			elif is_block:
				$End.global_position = collision_point
				break
			else:
				# 默认行为，激光在当前位置停止
				$End.global_position = collision_point
				break
		else:
			line.add_point(max_cast_to)
			$End.emitting = false
			break
