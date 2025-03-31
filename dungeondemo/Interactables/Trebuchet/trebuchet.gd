class_name Trebuchet extends Node2D

@export var charge: PackedScene

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var progress_bar_minigame: ProgressBarMinigame = $ProgressBarMinigame
@onready var interact_area: Area2D = $Area2D
@onready var marker: Marker2D = $Marker2D

signal item_created

var throw_distance: float = 0.0
var base_distance: float = 100.0  # 基础投掷距离
var weight_multiplier: float = 10.0  # 炸药重量对距离的影响系数
var time_multiplier: float = 5.0  # 完成时间对距离的影响系数

#@onready var game01: Game01 = get_parent().get_parent().get_node(game01_node_path)  # 获取父节点的`game01`

var game_active: bool = false  # 追踪游戏是否已启动

func _ready() -> void:
	# 连接区域进入和退出事件
	interact_area.area_entered.connect(OnAreaEnter)
	interact_area.area_exited.connect(OnAreaExit)
	
	# 确保初始时，小游戏界面是隐藏的
	progress_bar_minigame.visible = false

# 玩家进入区域时触发交互
func OnAreaEnter(_a: Area2D) -> void:
	PlayerManager.interact_pressed.connect(player_interact)

# 玩家离开区域时停止交互
func OnAreaExit(_a: Area2D) -> void:
	PlayerManager.interact_pressed.disconnect(player_interact)

# 玩家触发交互后开始小游戏
func player_interact() -> void:
	if not game_active:
		# 启动小游戏
		start_minigame()

func start_minigame() -> void:
	# 设置游戏为活动状态
	game_active = true
	
	# 显示进度条等小游戏界面
	progress_bar_minigame.visible = true
	
	# 启动小游戏计时
	progress_bar_minigame.start_game()

	# 连接小游戏完成的信号
	progress_bar_minigame.minigame_finished.connect(_on_minigame_finished)

func _on_minigame_finished(completion_time: float) -> void:
	var game01 = get_parent().get_parent().get_node("Game01")
	var ammo_weight = game01.get_ammo_weight()
	# 计算投掷距离
	throw_distance = base_distance + (ammo_weight * weight_multiplier) - (completion_time * time_multiplier)
	# 打印投掷距离
	print("Calculated throw distance: ", throw_distance)
	# 播放投掷动画
	animation_player.play("Throw")
	# 完成后隐藏小游戏界面并停止计时
	progress_bar_minigame.visible = false
	progress_bar_minigame.stop_game()  # 停止计时
	game_active = false  # 游戏结束

func _on_animation_frame_4():
	var charge_instance: Node = charge.instantiate()
	charge_instance.position = marker.position  # 使用 Marker 的位置
	var initial_velocity = Vector2(400, -200)  # 示例值，x 方向 200，y 方向 -300
	var predicted_y_position = marker.position.y + (initial_velocity.y * 0.5)  # 预测 y 位置
	if predicted_y_position < 0 or predicted_y_position > 460:
		initial_velocity.y = min(initial_velocity.y, 0)  # 限制 y 方向速度
	charge_instance.set_initial_velocity(initial_velocity)
	add_child(charge_instance)
	# 发出 item_created 信号
	emit_signal("item_created")
