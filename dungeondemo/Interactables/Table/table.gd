@tool
class_name Table extends Node

var is_open: bool = false

@export_file( "*.tscn" ) var game

@onready var interact_area: Area2D = $Area2D


func _ready() -> void:
	interact_area.area_entered.connect(OnAreaEnter)
	interact_area.area_exited.connect(OnAreaExit)

func player_interact() -> void:
	LevelManager.load_minigame(game)
	pass

func OnAreaEnter(_a: Area2D) -> void:
	PlayerManager.interact_pressed.connect(player_interact)

func OnAreaExit(_a: Area2D) -> void:
	PlayerManager.interact_pressed.disconnect(player_interact)
