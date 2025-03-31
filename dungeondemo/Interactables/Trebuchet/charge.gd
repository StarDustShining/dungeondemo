class_name Charge extends RigidBody2D

# 最大 y 位置
@export var max_y_position: float
@export var min_x_position: float
@export var x_velocity_decay: float

func _process(delta: float) -> void:
	# 检查 y 位置是否超过限制
	if global_position.y > max_y_position:
		global_position.y = max_y_position
		linear_velocity.y = 0  # 停止 y 方向运动
	linear_velocity.x *= x_velocity_decay
	if abs(linear_velocity.x) < min_x_position:
		linear_velocity.x = 0
	
# 设置初速度
func set_initial_velocity(velocity: Vector2) -> void:
	linear_velocity = velocity
