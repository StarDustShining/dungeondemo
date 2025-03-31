class_name ProgressBarMinigame extends Node2D

@onready var collimation: Node2D = $Collimation
@onready var progress_bar: Control = $ProgressBar

var start_time: float = 0.0  # 记录开始时间
var end_time: float = 0.0    # 记录结束时间
var is_paused: bool = false
var is_game_active: bool = false  # 控制游戏是否活跃

signal minigame_finished

func _ready():
	collimation.on_enemy_process.connect(_on_enemy_process)
	collimation.on_enemy_in_sight.connect(_on_enemy_in_sight)

# 处理进度
func _on_enemy_process(progress: float):
	if progress == 0.0 and not is_paused:  # 只有当游戏没有暂停时才开始计时
		start_time = Time.get_ticks_msec() / 1000.0  # 秒数
	elif progress >= 1.0 and not is_paused:
		end_time = Time.get_ticks_msec() / 1000.0  # 秒数
		var completion_time = end_time - start_time  # 计算游戏完成的时间
		print("完成时间: ", completion_time)
		emit_signal("minigame_finished", completion_time)

# 处理敌人进入视野
func _on_enemy_in_sight(count: int):
	is_paused = true  # 暂停游戏
	print("敌人被瞄准次数: ", count)

# 开始游戏时恢复计时
func start_game() -> void:
	is_paused = false  # 恢复计时
	is_game_active = true  # 游戏开始
	start_time = Time.get_ticks_msec() / 1000.0  # 记录游戏开始时间

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
