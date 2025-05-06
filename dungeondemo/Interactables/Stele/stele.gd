class_name Stele extends Node2D

@onready var interact_area: Area2D = $E
@onready var canvas_layer: CanvasLayer = $"../CanvasLayer"


func player_interact() -> void:
	canvas_layer.visible=true
	pass


func _ready() -> void:
	interact_area.area_entered.connect(OnAreaEnter)
	interact_area.area_exited.connect(OnAreaExit)

func OnAreaEnter(_a: Area2D) -> void:
	PlayerManager.interact_pressed.connect(player_interact)

func OnAreaExit(_a: Area2D) -> void:
	PlayerManager.interact_pressed.disconnect(player_interact)
