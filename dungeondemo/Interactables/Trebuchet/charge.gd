class_name Charge extends RigidBody2D

# 最大 y 位置
@export var max_y_position: float
@export var min_x_position: float
@export var x_velocity_decay: float
@export var gravity: float = 9.8  # 重力加速度
var debug_enabled: bool = false  # 调试标志
var debug_timer: float = 0.0  # 计时器
var debug_interval: float = 0.5  # 输出间隔（秒）

func _process(delta: float) -> void:
	# 检查 y 位置是否超过限制
	if global_position.y > max_y_position:
		global_position.y = max_y_position
		linear_velocity.y = 0  # 停止 y 方向运动
	# 检查 x 速度是否低于最小速度
	linear_velocity.x *= x_velocity_decay
	if abs(linear_velocity.x) < min_x_position:
		linear_velocity.x = 0
	# 应用重力
	linear_velocity.y += gravity * delta
	# 实时输出当前位置（如果调试标志为 true）
	if debug_enabled:
		debug_timer += delta
		if debug_timer >= debug_interval:
			print("Charge position: ", global_position)
			debug_timer = 0.0  # 重置计时器

# 设置初速度
func set_initial_velocity(velocity: Vector2) -> void:
	linear_velocity = velocity
