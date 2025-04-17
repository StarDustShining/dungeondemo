class_name Trebuchet extends Node2D

@export var charge: PackedScene
@export var progress_bar_minigame: PackedScene  # 导入 ProgressBarMinigame 场景

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var marker: Marker2D = $Marker2D
@onready var interact_area: Area2D = $E

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
	saved_completion_time = completion_time  # 保存完成时间
	var game01 = get_parent().get_parent().get_node("Game01")
	var ammo_weight = game01.get_ammo_weight()
	# 获取计数器值
	var counts = game01.get_counts()
	var charcoal_count = counts["charcoal_count"]
	var saltpetre_count = counts["saltpetre_count"]
	var sulphur_count = counts["sulphur_count"]
	
	# 根据 completion_time 调整力系数（时间越短，力越大）
	var force_multiplier = 2.5 / max(completion_time, 0.1)  # 防止除零错误
	# 播放投掷动画
	animation_player.play("Throw")
	# 发出 item_created 信号
	emit_signal("item_created")
	# 销毁当前的 ProgressBarMinigame
	if current_progress_bar_minigame:
		current_progress_bar_minigame.queue_free()
		current_progress_bar_minigame = null

func _on_animation_frame_4():
	var charge_instance: Node = charge.instantiate()
	charge_instance.position = marker.position  # 使用 Marker 的位置
	charge_instance.min_x_position = marker.position.x
	charge_instance.max_y_position = self.position.y
	
	# 获取计数器值
	var game01 = get_parent().get_parent().get_node("Game01")
	var counts = game01.get_counts()
	var charcoal_count = counts["charcoal_count"]
	var saltpetre_count = counts["saltpetre_count"]
	var sulphur_count = counts["sulphur_count"]
	
	# 计算比例评分
	var target_ratio = Vector3(3, 1, 2)
	var total_count = charcoal_count + saltpetre_count + sulphur_count
	if total_count == 0:
		total_count = 1  # 防止除零错误
	var actual_ratio = Vector3(charcoal_count, saltpetre_count, sulphur_count) / total_count
	var score = calculate_score(actual_ratio, target_ratio)
	
	# 根据评分调整 initial_velocity_max
	var base_velocity = 100.0  # 基础速度
	var max_velocity = 200.0  # 最大速度
	var initial_velocity_max = base_velocity + (max_velocity - base_velocity) * score
	
	# 设置 initial_velocity_max
	charge_instance.set_explosion_initial_velocity_max(initial_velocity_max)
	
	var ammo_weight = 0.01 * game01.get_ammo_weight()  # 调整火药质量
	var completion_time: float = saved_completion_time
	var force_multiplier = 5 / max(completion_time, 0.1)  # 防止除零错误
	var base_speed = 800.0  # 增加基础速度
	var initial_velocity = Vector2(
		(base_speed / max(ammo_weight, 0.1)) * force_multiplier,  # 水平速度
		(-300 / max(ammo_weight, 0.1)) * force_multiplier         # 垂直速度
	)
	
	charge_instance.set_initial_velocity(initial_velocity)
	add_child(charge_instance)
	# 发出 item_created 信号
	emit_signal("item_created")
	# 销毁 game01
	game01.queue_free()
	# 重置 Trebuchet 状态
	reset_trebuchet()

# 计算比例评分的方法
func calculate_score(actual_ratio: Vector3, target_ratio: Vector3) -> float:
	var diff = actual_ratio - target_ratio
	var score = 1.0 - diff.length() / target_ratio.length()
	return clamp(score, 0.0, 1.0)

func reset_trebuchet():
	game_active = false
	animation_player.stop()
	animation_player.seek(0)
