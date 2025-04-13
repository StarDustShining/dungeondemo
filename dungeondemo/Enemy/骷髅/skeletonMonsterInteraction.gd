class_name SkeletonMonsterInteractionHost extends Node2D

@onready var enemy: Enemy = $".."


func _ready() -> void:
	enemy.direction_changed.connect(UpdateDirection)
	pass


func UpdateDirection(new_direction: Vector2) -> void:
	# 左移 (new_direction.x < 0) → 设为正常方向
	# 右移 (new_direction.x > 0) → 设为水平翻转
	scale.x = -1 if new_direction.x > 0 else 1
	pass
