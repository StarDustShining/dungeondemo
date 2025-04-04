class_name Trebuchet extends Node2D

@export var charge: PackedScene
@export var progress_bar_minigame: PackedScene  # 导入 ProgressBarMinigame 场景

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var interact_area: Area2D = $Area2D
@onready var marker: Marker2D = $Marker2D
@onready var trajectory_line: Line2D = $Line2D

signal item_created

var game_active: bool = false  # 追踪游戏是否已启动
var current_progress_bar_minigame: ProgressBarMinigame = null
var saved_completion_time: float = 0.0  # 保存小游戏完成时间

func _ready() -> void:
	# 连接区域进入和退出事件
	interact_area.area_entered.connect(OnAreaEnter)
	interact_area.area_exited.connect(OnAreaExit)

# 玩家进入区域时触发交互
func OnAreaEnter(_a: Area2D) -> void:
	PlayerManager.interact_pressed.connect(player_interact)

# 玩家离开区域时停止交互
func OnAreaExit(_a: Area2D) -> void:
	PlayerManager.interact_pressed.disconnect(player_interact)

# 玩家触发交互后开始小游戏
func player_interact() -> void:
	# 检查玩家背包中是否有 powder
	var has_powder = false
	for slot in PlayerManager.INVENTORY_DATA.slots:
		if slot and slot.item_data and slot.item_data.resource_path == "res://Items/powder.tres":
			has_powder = true
			break
	if not has_powder:
		print("无法使用投石机，背包中没有 powder。")
		return
	# 删除玩家背包中的 powder
	for i in range(PlayerManager.INVENTORY_DATA.slots.size()):
		var slot = PlayerManager.INVENTORY_DATA.slots[i]
		if slot and slot.item_data and slot.item_data.resource_path == "res://Items/powder.tres":
			PlayerManager.INVENTORY_DATA.remove_item(i)
			break
	if not game_active:
		# 启动小游戏
		start_minigame()


func start_minigame() -> void:
	# 设置游戏为活动状态
	game_active = true
	# 动态添加 ProgressBarMinigame
	current_progress_bar_minigame = progress_bar_minigame.instantiate()
	add_child(current_progress_bar_minigame)
	current_progress_bar_minigame.set_can_start(true)  # 设置为可运行状态
	current_progress_bar_minigame.start_game()  # 启动小游戏
	current_progress_bar_minigame.minigame_finished.connect(_on_minigame_finished)  # 连接信号


func _on_minigame_finished(completion_time: float) -> void:
	clear_trajectory()  # 清除之前的轨迹线
	saved_completion_time = completion_time  # 保存完成时间
	var game01 = get_parent().get_parent().get_node("Game01")
	var ammo_weight = game01.get_ammo_weight()
	# 根据 completion_time 调整力系数（时间越短，力越大）
	var force_multiplier = 1.0 / max(completion_time, 0.1)  # 防止除零错误
	# 播放投掷动画
	animation_player.play("Throw")
	# 发出 item_created 信号
	emit_signal("item_created")
	# 销毁当前的 ProgressBarMinigame
	if current_progress_bar_minigame:
		current_progress_bar_minigame.queue_free()
		current_progress_bar_minigame = null

func reset_trebuchet():
	# 重置 Trebuchet 的状态
	game_active = false
	trajectory_line.points = []
	animation_player.stop()  # 停止动画播放器
	animation_player.seek(0)  # 将动画播放器重置到起始位置

func _on_animation_frame_4():
	var charge_instance: Node = charge.instantiate()
	charge_instance.position = marker.position  # 使用 Marker 的位置
	var game01 = get_parent().get_parent().get_node("Game01")
	var ammo_weight = 0.01 * game01.get_ammo_weight()  # 调整火药质量
	# 使用保存的 completion_time
	var completion_time: float = saved_completion_time
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
	# 销毁 game01
	game01.queue_free()
	# 重置 Trebuchet 状态
	reset_trebuchet()
	

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
