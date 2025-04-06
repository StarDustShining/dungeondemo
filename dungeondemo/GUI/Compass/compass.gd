class_name Compass extends CanvasLayer

@onready var spoon: Sprite2D = $spoon

var player: Node2D = null
var magnets: Array[Magnet] = []
var in_field := false
var in_specific_level := false

var rotation_speed := 5.0  # 控制旋转的平滑速度

func _ready():
	# 获取所有属于 "Magnet" 组的节点并加入 magnets 数组
	for node in get_tree().get_nodes_in_group("Magnet"):
		if node is Magnet:
			magnets.append(node)

func _process(delta: float) -> void:
	if in_specific_level and in_field and player and magnets.size() > 0:
		var closest = magnets[0]
		var min_dist = player.global_position.distance_to(closest.global_position)

		# 找到最近的磁石
		for m in magnets:
			var dist = player.global_position.distance_to(m.global_position)
			if dist < min_dist:
				min_dist = dist
				closest = m

		# 计算方向和角度
		var dir = closest.global_position - player.global_position
		var target_angle = dir.angle() + deg_to_rad(45)  # 初始朝东北方向，偏移45°

		# 平滑旋转磁勺
		spoon.rotation = lerp_angle(spoon.rotation, target_angle, rotation_speed * delta)
	else:
		# 离开磁场或不在关卡时，磁勺恢复默认朝向（正北偏 -45°）
		var default_angle = deg_to_rad(-45)
		spoon.rotation = lerp_angle(spoon.rotation, default_angle, rotation_speed * delta)

	# 控制整个指南针 UI 是否可见
	visible = in_specific_level

func set_in_specific_level(value: bool) -> void:
	in_specific_level = value
	visible = value
