extends Area2D

@export var ball_scene: PackedScene
@onready var marker = $Marker  # 预先获取 Marker 节点

var is_mouse_inside: bool = false  # 记录鼠标是否在区域内

func _ready():
	# 不再需要计时器，直接处理鼠标事件
	pass

# 当鼠标进入 Area2D 时触发
func _on_mouse_entered():
	is_mouse_inside = true  # 记录鼠标在区域内

# 当鼠标退出 Area2D 时触发
func _on_mouse_exited():
	is_mouse_inside = false  # 记录鼠标不在区域内

# 处理右键点击
func _input(event):
	if is_mouse_inside and Input.is_action_pressed("交互"):
		_on_ball_instance()  # 调用实例化函数

func _on_ball_instance():
	# 实例化球体
	var ball_instance: Node = ball_scene.instantiate()
	ball_instance.position = marker.position  # 使用 Marker 的位置
	add_child(ball_instance)
