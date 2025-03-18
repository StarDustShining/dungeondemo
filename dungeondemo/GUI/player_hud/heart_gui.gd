class_name HeartGUI extends Control


@onready var sprite: Sprite2D = $Sprite2D


var value : int = 2 :
	set( _value ):
		value = _value
		UpdateSprite()
		


func UpdateSprite() -> void:
	# 根据 value 反转帧
	sprite.frame = 2 - value  # 倒放，0 -> 2, 1 -> 1, 2 -> 0
