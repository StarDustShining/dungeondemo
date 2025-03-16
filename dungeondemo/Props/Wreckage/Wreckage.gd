class_name Wreckage extends Node2D

func _ready() -> void:
	$HitBox.damaged.connect(TakeDamage)
	pass
	

func TakeDamage(hurt_box:HurtBox)->void:
	queue_free()
	pass
