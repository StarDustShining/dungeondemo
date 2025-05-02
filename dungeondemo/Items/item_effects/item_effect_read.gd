class_name ItemEffectRead extends ItemEffect

@export var image_path: String = "res://Items/sprites/oldroll.png"
signal request_show_image(path: String)

#func use() -> void:
func use() -> bool:
	emit_signal("request_show_image", image_path)
	return false #不真正消耗该物品
