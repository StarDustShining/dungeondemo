extends Node2D

# 引用 CPUParticles2D 和 CollisionShape2D 节点
@onready var collision_shape: CollisionShape2D = $HurtBox/CollisionShape2D
@onready var cpu_particles: CPUParticles2D = $CPUParticles2D
@onready var capsule_shape = collision_shape.shape

# 设置 initial_velocity_max 的方法
func set_initial_velocity_max(initial_velocity_max: float):
	# 输出调试信息
	print("Setting initial_velocity_max: ", initial_velocity_max)
	cpu_particles.initial_velocity_max = initial_velocity_max

# 根据 CPUParticles2D 的属性设置 CollisionShape2D 大小的方法
func adjust_collision_shape():
	var initial_velocity_max = cpu_particles.initial_velocity_max
	var direction = cpu_particles.direction
	var gravity = cpu_particles.gravity
	var lifetime = cpu_particles.lifetime
	
	# 输出调试信息
	print("Adjusting collision shape with initial_velocity_max: ", initial_velocity_max)

	var horizontal_velocity = initial_velocity_max * direction.x
	var vertical_velocity = initial_velocity_max * direction.y
	
	var max_horizontal_distance = horizontal_velocity * lifetime
	var max_vertical_velocity = initial_velocity_max * sin(direction.angle())
	var max_vertical_distance = max_vertical_velocity * lifetime - 0.5 * gravity.y * lifetime * lifetime
	
	var new_radius = abs(max_vertical_distance)
	var new_height = abs(max_horizontal_distance)
	
	capsule_shape.radius = new_radius
	capsule_shape.height = new_height

# 初始化
func _ready():
	adjust_collision_shape()
	cpu_particles.emitting = true
	start_self_destruction()

# 启动自毁逻辑（等待粒子生命周期结束后销毁自身）
func start_self_destruction():
	await get_tree().create_timer(cpu_particles.lifetime).timeout
	queue_free()
