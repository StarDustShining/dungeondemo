class_name SulphurBottle extends Area2D
@onready var sulphur_bottle: Area2D = $"."

@export var ball_scene: PackedScene
@export var sand: AudioStream
@onready var marker = $Marker  # 预先获取 Marker 节点
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_mouse_inside: bool = false  # 记录鼠标是否在区域内
var can_instantiate: bool = true   # 控制是否可以实例化

signal item_created

func _ready():
	# 不再需要计时器，直接处理鼠标事件
	pass

# 当鼠标进入 Area2D 时触发
func _on_mouse_entered():
	is_mouse_inside = true  # 记录鼠标在区域内

# 当鼠标退出 Area2D 时触发
func _on_mouse_exited():
	is_mouse_inside = false  # 记录鼠标不在区域内

# 处理输入事件
func _unhandled_input(event):
	# 只要交互键松开，禁用实例化，且只针对当前节点
	if is_mouse_inside and Input.is_action_just_released("交互"):
		can_instantiate = false  # 禁用当前节点的实例化
		audio.stop()  # 停止音频
		animation_player.stop()  # 停止动画

	# 检测是否按下交互键并且允许实例化
	if is_mouse_inside and Input.is_action_pressed("交互") and can_instantiate:
		_on_ball_instance()  # 调用实例化函数
		animation_player.play("shake")
		
		# 播放音频
		if not audio.playing:  # 确保音频只播放一次
			audio.stream = sand
			audio.stream.loop = true
			audio.play()  # 播放音频

# 实例化球体
func _on_ball_instance():
	# 实例化球体
	var ball_instance: Node = ball_scene.instantiate()
	ball_instance.position = marker.position  # 使用 Marker 的位置
	add_child(ball_instance)
	# 发出 item_created 信号
	emit_signal("item_created")
