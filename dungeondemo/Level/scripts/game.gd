class_name Game extends Node2D

signal minigame_finished  # 定义信号

func _ready():
	#process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(true)
	set_process_input(true)
	set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("退出"):
		end_minigame()

func end_minigame():
	minigame_finished.emit()  # 触发小游戏完成信号
	queue_free()  # 清除小游戏
