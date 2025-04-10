class_name Mozi extends CharacterBody2D

@onready var interact_area: Area2D = $Area2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	interact_area.area_entered.connect(OnAreaEnter)
	interact_area.area_exited.connect(OnAreaExit)


func OnAreaEnter(_a: Area2D) -> void:
	PlayerManager.interact_pressed.connect(player_interact)

func OnAreaExit(_a: Area2D) -> void:
	PlayerManager.interact_pressed.disconnect(player_interact)
	animated_sprite.stop()

func player_interact() -> void:
	animated_sprite.play("say")
	DialogueManager.show_example_dialogue_balloon(load("res://NPC/Mozi/Mozi.dialogue"),"start")
	PlayerManager.interact_pressed.disconnect(player_interact)
