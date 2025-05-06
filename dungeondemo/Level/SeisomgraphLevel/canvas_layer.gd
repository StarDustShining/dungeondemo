extends CanvasLayer

@onready var player:Player=PlayerManager.player
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("退出"):
		self.visible=false


func _on_visibility_changed() -> void:
	if self.visible:
		animated_sprite.stop()
		animated_sprite.play("default")
