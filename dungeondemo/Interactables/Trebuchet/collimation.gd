extends Node2D

@export var enemy_think_time: float = 4.0
@export var enemy_move_speed: float = 2.0
@export var hook_pull_power: float = 0.5
@export var hook_gravity: float = 0.05
@export var hook_size: float = 0.2
@export var hook_power: float = 0.1
@export var hook_bounce_factor: float = 0.5  # 反弹系数（越接近1，反弹越大）

@onready var hook: Sprite2D = $Hook
@onready var enemy: Sprite2D = $Enemy
@onready var top_pivot: Node2D = $TopPivot
@onready var bottom_pivot: Node2D = $BottomPivot

var enemy_timer: float = 0.0
var enemy_position: float = 0.5
var enemy_target_pos: float = 0.5

var hook_position: float = 0.5
var hook_velocity: float = 0.0
var hook_progress: float = 0.0

var is_paused: bool = false
var enemy_in_sight_count: int = 0

signal on_enemy_in_sight(count)
signal on_enemy_process(progress)

func _ready():
	enemy.global_position = calculate_position(0.5)

func _process(delta):
	if is_paused:
		return
	if Input.is_action_just_pressed("重新开始"):
		restart()
	process_enemy(delta)
	process_hook(delta)
	detect_progress(delta)

# 敌人移动逻辑
func process_enemy(time_delta: float):
	enemy_timer -= time_delta
	if enemy_timer < 0.0:
		enemy_timer = enemy_think_time * randf()
		enemy_target_pos = randf()

	enemy_position = lerp(enemy_position, enemy_target_pos, enemy_move_speed * time_delta)
	enemy.global_position = calculate_position(enemy_position)

# Hook 物理逻辑 + 反弹
func process_hook(time_delta: float):
	if Input.is_action_pressed("交互"):
		hook_velocity += hook_pull_power * time_delta

	hook_velocity -= hook_gravity * time_delta
	hook_position += hook_velocity
	hook_position = clamp(hook_position, hook_size / 2.0, 1.0 - hook_size / 2.0)

	# 反弹逻辑
	if hook_position == hook_size / 2.0 and hook_velocity < 0.0:
		hook_velocity = -hook_velocity * hook_bounce_factor  # 触底反弹
	elif hook_position == 1.0 - hook_size / 2.0 and hook_velocity > 0.0:
		hook_velocity = -hook_velocity * hook_bounce_factor  # 触顶反弹

	hook.global_position = calculate_position(hook_position)

# 检测进度条增长或减少
func detect_progress(time_delta: float):
	var hook_top_boundary = hook_position + hook_size / 2.0
	var hook_bottom_boundary = hook_position - hook_size / 2.0

	if hook_bottom_boundary < enemy_position and enemy_position < hook_top_boundary:
		add_progress(hook_power * time_delta)  # 瞄准成功，增加进度
	else:
		add_progress(-hook_power * time_delta * 0.5)  # 瞄准失败，进度回退

	if hook_progress >= 1.0:
		aim_enemy()

# 进度调整（确保不低于0）
func add_progress(amount: float):
	hook_progress = max(0.0, hook_progress + amount)
	emit_signal("on_enemy_process", hook_progress)

func set_progress(to: float):
	hook_progress = max(0.0, to)
	emit_signal("on_enemy_process", hook_progress)

# 瞄准成功
func aim_enemy():
	print("成功瞄准敌人方向！")
	is_paused = true
	enemy_in_sight_count += 1
	emit_signal("on_enemy_in_sight", enemy_in_sight_count)

# 计算挂钩的坐标位置
func calculate_position(normalized_position: float) -> Vector2:
	normalized_position = 1.0 - normalized_position
	var new_pos = bottom_pivot.global_position - top_pivot.global_position
	new_pos *= normalized_position
	new_pos += top_pivot.global_position
	return new_pos

# 重新开始游戏
func restart():
	hook_position = 0.0
	hook_velocity = 0.0
	set_progress(0.0)
	is_paused = false
