class_name Charge extends RigidBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var has_exploded: bool = false
var max_y_position: float = 0.0
var min_x_position: float = 0.0
var x_velocity_decay: float = 0.98
var gravity: float = 9.8
var initial_velocity_max: float = 100.0  # 初始速度最大值
var explosion_delay: float = 0.0  # 爆炸延迟计时器

func _ready() -> void:
	animation_player.play("light")
	pass

func _process(delta: float) -> void:
	# 只在未爆炸时处理
	if has_exploded:
		return

	# 检查 y 位置是否超过限制
	if global_position.y > max_y_position:
		global_position.y = max_y_position
		linear_velocity.y = 0

		# 确保第一次触发爆炸
		trigger_explosion()
		return

	# 水平方向减速
	linear_velocity.x *= x_velocity_decay
	if abs(linear_velocity.x) < min_x_position:
		linear_velocity.x = 0

	# 应用重力
	linear_velocity.y += gravity * delta

func trigger_explosion():
	if has_exploded:
		return
	has_exploded = true

	# 设置为静态物体，彻底停止物理运算
	freeze = true  # 禁用物理仿真
	lock_rotation = true  # 锁定旋转
	animation_player.play("explode")  # 播放爆炸动画并停止light动画
	
	# 创建爆炸特效
	var explosion_effect_scene = preload("res://Interactables/Trebuchet/ExplosionEffect.tscn")
	var explosion_effect_instance = explosion_effect_scene.instantiate()

	# 使用 global_position 来确保特效的位置正确
	explosion_effect_instance.position = position  # 设置为 RigidBody2D 的位置
	# 在动画播放结束后显示爆炸特效
	await animation_player.animation_finished  # 等待动画播放完成
	get_parent().add_child(explosion_effect_instance)

	# 设置 explosion_effect 的 initial_velocity_max
	explosion_effect_instance.set_initial_velocity_max(initial_velocity_max)

	# 爆炸动画完成后销毁炸弹节点
	await get_tree().create_timer(5.0).timeout  # 等待5秒后销毁炸弹节点
	queue_free()  # 销毁当前节点（炸弹）

func set_initial_velocity(velocity: Vector2) -> void:
	linear_velocity = velocity

func set_explosion_initial_velocity_max(value: float) -> void:
	initial_velocity_max = value
