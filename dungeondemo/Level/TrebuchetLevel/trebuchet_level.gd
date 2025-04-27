class_name TrebuchetLevel extends Node2D

func _ready() -> void:
	self.y_sort_enabled = true
	PlayerManager.set_as_parent(self)
	PlayerManager.player.visible=true
	PlayerManager.player.position=get_node("PlayerSpawn").position
	PlayerManager.player.top_down = false
	PlayerManager.player._ready()  # 确保 Player 的 _ready() 函数被调用
	LevelManager.level_load_started.connect(_free_level)
	LevelManager.minigame_load_started.connect(_pause_level)

# 不销毁场景，而是仅清除与小游戏相关的部分
func _free_level() -> void:
	# 如果你只需要清理小游戏相关的内容，而不是销毁整个场景
	PlayerManager.unparent_player(self)  # 如果需要可以解除父子关系，但不销毁主场景

func _pause_level() -> void:
	pass


func _on_area_2d_area_entered(area: Area2D) -> void:
	var video_player=get_node("CanvasLayer/VideoStreamPlayer")
	get_tree().paused = true  # 暂停游戏
	await video_player.play();
	get_tree().paused = false
	pass # Replace with function body.
