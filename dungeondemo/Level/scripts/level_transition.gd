@tool
class_name LevelTransition extends Area2D

signal entered_from_here

enum SIDE { LEFT, RIGHT, TOP, BOTTOM }

@export_file( "*.tscn" ) var level
@export var target_transition_area : String = "LevelTransition"
@export var center_player : bool = false

@export_category("Collision Area Settings")

@export_range( 1, 12, 1, "or_greater") var size : int = 3 :
	set( _v ):
		size = _v
		_update_area()

@export var side: SIDE = SIDE.LEFT :
	set( _v ):
		side = _v
		_update_area()

@export var snap_to_grid : bool = false :
	set ( _v ):
		_snap_to_grid()

@onready var collision_shape: CollisionShape2D = $CollisionShape2D




func _ready() -> void:
	_update_area()
	if Engine.is_editor_hint():
		return
	
	monitoring = false
	_place_player()
	
	await LevelManager.level_loaded

	await get_tree().physics_frame
	await get_tree().physics_frame
	
	# 设置碰撞掩码以确保能检测到不同类型的玩家
	collision_layer = 0
	collision_mask = 1 | 2 | 4 | 8 | 16 | 32 | 64  # 添加所有可能的玩家层
	monitorable = true
	monitoring = true
	
	# 断开之前的连接，确保不会重复连接
	if area_entered.is_connected(_player_entered):
		area_entered.disconnect(_player_entered)
		
	# 重新连接信号
	area_entered.connect(_player_entered)
	
	# 添加额外的信号连接
	body_entered.connect(_body_entered)
	
	print("LevelTransition 已准备好，碰撞掩码设置为:", collision_mask)
	pass

func _body_entered(body: Node2D) -> void:
	print("碰撞到物体:", body.name, ", 类型:", body.get_class())
	
	# 检查是否是 downplayer 或普通 player
	if body.name.contains("player") or body.name.contains("Player") or body.is_in_group("player"):
		print("检测到玩家，准备切换场景")
		
		# 如果是 downplayer，保存其血量到全局
		if body.has_method("UpdateHp") and body.get("hp") != null and body.get("max_hp") != null:
			var player_manager = get_node_or_null("/root/PlayerManager")
			if player_manager and player_manager.has_method("set_health"):
				player_manager.set_health(body.hp, body.max_hp)
				print("保存玩家血量:", body.hp, "/", body.max_hp)
		
		await get_tree().create_timer(0.2).timeout
		LevelManager.load_new_level(level, target_transition_area, get_offset())

func _player_entered(_p: Node2D) -> void:
	print("区域检测到物体进入：", _p.name, ", 类型:", _p.get_class())
	
	# 如果是 player，保存其血量到全局
	if _p.has_method("UpdateHp") and _p.get("hp") != null and _p.get("max_hp") != null:
		var player_manager = get_node_or_null("/root/PlayerManager")
		if player_manager and player_manager.has_method("set_health"):
			player_manager.set_health(_p.hp, _p.max_hp)
			print("保存玩家血量:", _p.hp, "/", _p.max_hp)
	
	# 短暂等待，防止重复触发
	await get_tree().create_timer(0.5).timeout
	
	print("正在转换到新场景：", level)
	LevelManager.load_new_level(level, target_transition_area, get_offset())
	pass


func _place_player() -> void:
	if name != LevelManager.target_transition:
		return
	
	# 特殊处理迷宫关卡场景
	var current_scene = get_tree().current_scene
	var scene_path = current_scene.scene_file_path if current_scene else ""
	
	if scene_path.contains("labyrinth_level") or scene_path.contains("LabyrinthLevel"):
		# 在迷宫关卡中，强制使用固定坐标
		print("迷宫关卡场景，使用固定坐标(1500, 200)")
		PlayerManager.set_player_position(Vector2(1500, 200))
	else:
		# 其他场景使用原有逻辑
		PlayerManager.set_player_position(global_position + LevelManager.position_offset)
	
	entered_from_here.emit()


func get_offset() -> Vector2:
	var offset : Vector2 = Vector2.ZERO
	var player_pos = PlayerManager.player.global_position
	
	if side == SIDE.LEFT or side == SIDE.RIGHT:
		if center_player == true:
			offset.y = 0
		else:
			offset.y = player_pos.y - global_position.y
		offset.x = 32
		if side == SIDE.LEFT:
			offset.x *= -1
	else:
		if center_player == true:
			offset.x = 0
		else:
			offset.x = player_pos.x - global_position.x
		offset.y = 32
		if side == SIDE.TOP:
			offset.y *= -1

	return offset

func _update_area() -> void:
	var new_rect : Vector2 = Vector2( 32, 32 )
	var new_position : Vector2 = Vector2.ZERO
	
	if side == SIDE.TOP:
		new_rect.x *= size
		new_position.y -= 32
	elif side == SIDE.BOTTOM:
		new_rect.x *= size
		new_position.y += 32
	elif side == SIDE.LEFT:
		new_rect.y *= size
		new_position.x -= 32
	elif side == SIDE.RIGHT:
		new_rect.y *= size
		new_position.x += 32
	
	if collision_shape == null:
		collision_shape = get_node("CollisionShape2D")
	
	collision_shape.shape.size = new_rect
	collision_shape.position = new_position


func _snap_to_grid() -> void:
	position.x = round( position.x / 16 ) * 16
	position.y = round( position.y / 16 ) * 16
