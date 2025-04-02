class_name Trebuchet extends Node2D

@export var charge: PackedScene

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var progress_bar_minigame: ProgressBarMinigame = $ProgressBarMinigame
@onready var interact_area: Area2D = $Area2D
@onready var marker: Marker2D = $Marker2D
@onready var trajectory_line: Line2D = $Line2D


signal item_created

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
	clear_trajectory()  # 清除之前的轨迹线
	var game01 = get_parent().get_parent().get_node("Game01")
	var ammo_weight = game01.get_ammo_weight()
	# 根据 completion_time 调整力系数（时间越短，力越大）
	var force_multiplier = 1.0 / max(completion_time, 0.1)  # 防止除零错误
	# 播放投掷动画
	animation_player.play("Throw")
	# 完成后隐藏小游戏界面并停止计时
	progress_bar_minigame.visible = false
	progress_bar_minigame.stop_game()  # 停止计时
	game_active = false  # 游戏结束

func _on_animation_frame_4():
	var charge_instance: Node = charge.instantiate()
	charge_instance.position = marker.position  # 使用 Marker 的位置
	var game01 = get_parent().get_parent().get_node("Game01")
	var ammo_weight = 0.01 * game01.get_ammo_weight()  # 调整火药质量
	var completion_time: float = progress_bar_minigame.completion_time
	# 根据 completion_time 调整力系数（时间越短，力越大）
	var force_multiplier = 1.0 / max(completion_time, 0.1)  # 防止除零错误
	# 根据火药质量和力系数调整初始速度
	var base_speed = 1000.0  # 增加基础速度
	var initial_velocity = Vector2(
		(base_speed / max(ammo_weight, 0.1)) * force_multiplier,  # 水平速度
		(-500 / max(ammo_weight, 0.1)) * force_multiplier         # 垂直速度
	)
	# 从 charge_instance 中获取 max_y_position 和 min_x_position
	var max_y_position = charge_instance.max_y_position
	var min_x_position = charge_instance.min_x_position
	# 计算轨迹点，传入 max_y_position 和 min_x_position
	var gravity = 9.8  # 重力加速度
	var trajectory_points = calculate_trajectory_points(
		marker.position, initial_velocity, gravity, max_y_position, min_x_position
	)
	# 更新轨迹线
	trajectory_line.points = trajectory_points
	# 确保抛物线运动
	var time_of_flight = (2 * initial_velocity.y) / gravity  # 飞行时间
	var horizontal_distance = initial_velocity.x * time_of_flight  # 水平距离
	print("Ammo weight: ", ammo_weight)
	print("Completion time: ", completion_time)
	print("Force multiplier: ", force_multiplier)
	print("Initial velocity: ", initial_velocity)
	print("Predicted horizontal distance: ", horizontal_distance)
	charge_instance.set_initial_velocity(initial_velocity)
	add_child(charge_instance)
	# 发出 item_created 信号
	emit_signal("item_created")
	

func calculate_trajectory_points(initial_position: Vector2, initial_velocity: Vector2, gravity: float, max_y: float, min_x: float, num_points: int = 20) -> Array:
	var points: Array = []
	var time_step: float = 0.1  # 时间步长
	for i in range(num_points):
		var t: float = i * time_step
		var x: float = initial_position.x + initial_velocity.x * t
		var y: float = initial_position.y + initial_velocity.y * t + 0.5 * gravity * t * t
		# 检查 y 位置是否超过最大高度
		if y > max_y:
			y = max_y
			break  # 停止计算，因为火药已经到达最大高度
		# 检查 x 速度是否低于最小速度
		if abs(initial_velocity.x) < min_x:
			break  # 停止计算，因为火药已经停止水平运动
		points.append(Vector2(x, y))
	return points

func clear_trajectory() -> void:
	trajectory_line.points = []
