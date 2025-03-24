class_name Level extends Node2D

@export var music : AudioStream

func _ready() -> void:
	self.y_sort_enabled = true
	PlayerManager.set_as_parent(self)
	LevelManager.level_load_started.connect(_free_level)
	LevelManager.minigame_load_started.connect(_pause_level)

# 不销毁场景，而是仅清除与小游戏相关的部分
func _free_level() -> void:
	# 如果你只需要清理小游戏相关的内容，而不是销毁整个场景
	PlayerManager.unparent_player(self)  # 如果需要可以解除父子关系，但不销毁主场景
	queue_free()  # 不销毁当前场景，避免主场景消失

func _pause_level() -> void:
	pass
