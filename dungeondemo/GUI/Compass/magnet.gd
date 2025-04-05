class_name Magnet extends Node2D

signal player_entered_field(player)
signal player_exited_field(player)

@onready var magnetic_field: Area2D = $MagneticField

var player_in_field := false  # 标记玩家是否在磁场中

func _ready():
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
