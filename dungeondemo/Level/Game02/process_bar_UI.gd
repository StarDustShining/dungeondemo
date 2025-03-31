extends Control

@onready var progress_bar: ProgressBar = $ProgressBar


func _ready():
	pass  # 初始化时不需要额外的逻辑


func on_enemy_process(progress: float):
	progress_bar.value = progress * 100.0
