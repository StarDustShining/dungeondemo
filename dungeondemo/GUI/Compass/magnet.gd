class_name Magnet extends Node2D

signal player_entered_field(player)
signal player_exited_field(player)

@onready var magnetic_field: Area2D = $MagneticField  # 获取MagneticField节点

@export var magnetic_field_size: Vector2 = Vector2(200, 200)  # 默认磁场大小
var player_in_field := false  # 标记玩家是否在磁场中

# 动态实例化 CollisionShape2D 的函数
func _ready():
	# 创建并实例化 CollisionShape2D
	var collision_shape_2d = CollisionShape2D.new()
	var rectangle_shape = RectangleShape2D.new()
	rectangle_shape.extents = magnetic_field_size / 2  # 设置碰撞体的大小

	collision_shape_2d.shape = rectangle_shape
	magnetic_field.add_child(collision_shape_2d)  # 将其作为 MagneticField 的子节点添加

	# 将其放置在 MagneticField 的位置
	collision_shape_2d.position = Vector2.ZERO

	# 连接信号
	magnetic_field.body_entered.connect(_on_MagneticField_body_entered)
	magnetic_field.body_exited.connect(_on_MagneticField_body_exited)

func _on_MagneticField_body_entered(body):
	if body is Player:
		player_in_field = true
		player_entered_field.emit(body)

func _on_MagneticField_body_exited(body):
	if body is Player:
		player_in_field = false
		player_exited_field.emit(body)

func is_player_in_field() -> bool:
	return player_in_field
