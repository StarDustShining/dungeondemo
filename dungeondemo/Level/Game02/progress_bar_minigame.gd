class_name ProgressBarMinigame extends Node2D

@onready var collimation: Node2D = $Collimation
@onready var progress_bar: ProgressBar = $ProgressBar

var start_time: float = 0.0  # 记录开始时间
var end_time: float = 0.0    # 记录结束时间
var is_paused: bool = false
var is_game_active: bool = false  # 控制游戏是否活跃
var completion_time: float
var can_start: bool = false  # 标志位，控制小游戏是否可以运行

signal minigame_finished

func _ready():
	# 初始化时隐藏小游戏界面
	self.visible = false
	# 确保进度条归零
	progress_bar.value = 0
	collimation.on_enemy_process.connect(_on_enemy_process)
	collimation.on_enemy_in_sight.connect(_on_enemy_in_sight)

# 处理进度
func _on_enemy_process(progress: float):
	print("_on_enemy_process 被触发，progress: ", progress)
	if progress == 0.0 and not is_paused and can_start:  # 只有当游戏没有暂停且可以运行时才开始计时
		start_time = Time.get_ticks_msec() / 1000.0  # 秒数
	elif progress >= 1.0 and not is_paused:
		end_time = Time.get_ticks_msec() / 1000.0  # 秒数
		completion_time = end_time - start_time  # 计算游戏完成的时间
		print("完成时间: ", completion_time)
		emit_signal("minigame_finished", completion_time)
		# 重置 ProgressBarMinigame 状态
		reset_game()

# 处理敌人进入视野
func _on_enemy_in_sight(count: int):
	print("_on_enemy_in_sight 被触发，count: ", count)
	is_paused = true  # 暂停游戏

# 开始游戏时恢复计时
func start_game() -> void:
	if not can_start:
		print("警告: ProgressBarMinigame 尚未准备好运行。")
		return
	is_paused = false  # 恢复计时
	is_game_active = true  # 游戏开始
	start_time = Time.get_ticks_msec() / 1000.0  # 记录游戏开始时间
	progress_bar.value = 0  # 重置进度条
	self.visible = true  # 显示小游戏界面
	
	# 确保 can_start 标志位被正确设置
	can_start = true
	print("ProgressBarMinigame 已启动，can_start 设置为 true。")

# 暂停游戏时停止计时
func stop_game() -> void:
	is_paused = true  # 暂停计时
	is_game_active = false  # 游戏结束
	end_time = Time.get_ticks_msec() / 1000.0  # 记录游戏结束时间

# 获取游戏完成时间
func get_completion_time() -> float:
	if is_game_active:  # 如果游戏正在进行
		return Time.get_ticks_msec() / 1000.0 - start_time
	else:
		return end_time - start_time  # 如果游戏已结束



# 重置 ProgressBarMinigame 的状态
func reset_game():
	is_paused = false
	is_game_active = false
	can_start = false  # 重置标志位
	start_time = 0.0
	end_time = 0.0
	completion_time = 0.0
	progress_bar.value = 0  # 重置进度条
	self.visible = false  # 隐藏小游戏界面
	
	# 检查 collimation 是否存在
	if not collimation:
		print("错误: collimation 节点不存在。")
		return
	
	# 调用 collimation 的重置方法（如果存在）
	if collimation.has_method("reset"):
		collimation.reset()
		print("collimation 已调用 reset 方法。")
	else:
		print("警告: collimation 没有 reset 方法。")
	
	# 重新连接 collimation 的信号
	if collimation.has_signal("on_enemy_process") and collimation.has_signal("on_enemy_in_sight"):
		collimation.on_enemy_process.disconnect(_on_enemy_process)
		collimation.on_enemy_in_sight.disconnect(_on_enemy_in_sight)
		collimation.on_enemy_process.connect(_on_enemy_process)
		collimation.on_enemy_in_sight.connect(_on_enemy_in_sight)
		print("collimation 的信号已重新连接。")
	else:
		print("错误: collimation 缺少必要的信号。")

# 设置小游戏为可运行状态
func set_can_start(value: bool):
	can_start = value
