extends ProgressBar

func _ready():
	pass  # 初始化时不需要额外的逻辑


func on_enemy_process(progress: float):
	self.value = progress * 100.0
