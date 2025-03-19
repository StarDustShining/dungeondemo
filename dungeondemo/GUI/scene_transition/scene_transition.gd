extends CanvasLayer

@onready var animation_player: AnimationPlayer = $Control/AnimationPlayer


func FadeOut() -> bool:
	animation_player.play("fade_out")
	await animation_player.animation_finished
	return true


func FadeIn() -> bool:
	animation_player.play("fade_in")
	await animation_player.animation_finished
	return true
