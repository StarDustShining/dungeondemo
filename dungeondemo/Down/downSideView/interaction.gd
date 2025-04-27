class_name DownskeletonInteractionHost extends Node2D

@onready var downskeleton: CharacterBody2D = $".."


func _ready() -> void:
	downskeleton.DirectionChanged.connect(UpdateDirection)
	pass

# 监听方向变化
func UpdateDirection(new_direction: Vector2) -> void:
	match new_direction:
		Vector2.DOWN:
			rotation_degrees = 0
		Vector2.UP:
			rotation_degrees = 180
		Vector2.LEFT:
			rotation_degrees = 90
		Vector2.RIGHT:
			rotation_degrees = -90
		Vector2(-1, -1):
			rotation_degrees = 135
		Vector2(-1, 1):
			rotation_degrees = 45
		Vector2(1, -1):
			rotation_degrees = -135
		Vector2(1, 1):
			rotation_degrees = -45
		_:
			rotation_degrees = 0
