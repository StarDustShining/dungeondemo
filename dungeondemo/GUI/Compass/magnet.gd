class_name Magnet extends Node2D


# 磁石的位置
var magnet_position = Vector2(0, 0)

signal player_entered()

@onready var magneticfield_area: Area2D = $Area2D


func _ready():
	# 初始化磁石位置，可以根据需要调整
	magnet_position = global_position
	# 连接信号
	magneticfield_area.body_entered.connect(_on_MagnetArea_body_entered)
	magneticfield_area.body_exited.connect(_on_MagnetArea_body_exited)

func _on_MagnetArea_body_entered(body):
	if body.is_in_group("player_group"):
		# 发送信号给指南针场景
		get_tree().call_group("compass_group", "player_entered_magnet_area", magnet_position)

func _on_MagnetArea_body_exited(body):
	if body.is_in_group("player_group"):
		# 发送信号给指南针场景
		get_tree().call_group("compass_group", "player_exited_magnet_area")
