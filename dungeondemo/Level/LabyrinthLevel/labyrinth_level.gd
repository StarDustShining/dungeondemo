class_name LabyrinthLevel extends Node2D

@export var music : AudioStream

@onready var player: Player = get_node("/root/PlayerManager").player
@onready var compass: Compass = $Compass
@onready var vision_range: CollisionShape2D = $VisionRange
@onready var mask_layer: ColorRect = $MaskLayer
@onready var area_2d: Area2D = $Area2D
@onready var go_out_video_player: VideoStreamPlayer = $CanvasLayer/GoOutVideoPlayer


var magnets: Array[Magnet] = []  # 存储所有磁石节点

func _ready() -> void:
	self.y_sort_enabled = true	
	PlayerManager.set_as_parent(self)
	PlayerManager.player.top_down = false
	PlayerManager.player._ready()  # 确保 Player 的 _ready() 函数被调用
	LevelManager.level_load_started.connect(_free_level)
	LevelManager.minigame_load_started.connect(_pause_level)
	mask_layer.size = Vector2(5000,5000)
	mask_layer.position = Vector2.ZERO

	# 获取所有磁石节点并将它们存储在 magnets 数组中
	magnets.clear()
	for node in get_tree().get_nodes_in_group("Magnet"):
		if node is Magnet:
			magnets.append(node as Magnet)

	# 连接磁石的信号
	for magnet in magnets:
		magnet.player_entered_field.connect(_on_player_entered_field)
		magnet.player_exited_field.connect(_on_player_exited_field)
	
	# 设置指南针在特定关卡中显示
	compass.set_in_specific_level(true)

# 处理玩家进入磁场
func _on_player_entered_field(player: Player) -> void:
	compass.player = player
	compass.in_field = true

# 处理玩家离开磁场
func _on_player_exited_field(player: Player) -> void:
	compass.in_field = false

# 不销毁场景，而是仅清除与小游戏相关的部分
func _free_level() -> void:
	# 如果你只需要清理小游戏相关的内容，而不是销毁整个场景
	PlayerManager.unparent_player(self)  # 如果需要可以解除父子关系，但不销毁主场景
	queue_free()  # 不销毁当前场景，避免主场景消失

func _pause_level() -> void:
	pass

func _process(delta: float) -> void:
	var vision_shape = vision_range.shape as CircleShape2D
	var vision_radius = vision_shape.radius
	var player_position = player.global_position
	var mask_position = mask_layer.global_position
	var mask_size = mask_layer.size

	# 转换为 0~1 的 UV 坐标
	var center_relative = (player_position - mask_position) / mask_size

	# 更新 Shader 参数
	var mask_material = mask_layer.material as ShaderMaterial
	if mask_material:
		mask_material.set_shader_parameter("center", center_relative)
		# 注意归一化 radius（除以对角线长度）
		mask_material.set_shader_parameter("radius", vision_radius / mask_size.length())
		mask_material.set_shader_parameter("softness", 0.05)


func _on_area_2d_area_entered(area: Area2D) -> void:
	go_out_video_player.play();
	pass # Replace with function body.
