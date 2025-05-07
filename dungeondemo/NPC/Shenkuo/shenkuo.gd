class_name Shenkuo extends CharacterBody2D

@onready var interact_area: Area2D = $E
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


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
	DialogueManager.show_example_dialogue_balloon(load("res://NPC/Shenkuo/Shenkuo.dialogue"), "start")
	DialogueManager.dialogue_ended.connect(on_dialogue_ended)
	PlayerManager.interact_pressed.disconnect(player_interact)

func on_dialogue_ended(_resource: DialogueResource) -> void:
	animation_player.play("fadeout")
	self.queue_free()  # 或者 self.visible = false 如果你只是想隐藏而不是删除
	# 断开对话结束信号
	DialogueManager.dialogue_ended.disconnect(on_dialogue_ended)
