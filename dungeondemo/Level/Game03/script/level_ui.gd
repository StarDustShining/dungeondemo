extends Control

@onready var levels_timer := Timer.new()
@onready var levels: Sprite2D = $CanvasLayer/Levels
@onready var levels_anim: AnimationPlayer = $CanvasLayer/Levels/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(levels_timer)
	levels.visible = false
	levels_timer.one_shot = true
	levels_timer.connect("timeout", Callable(self, "_on_levels_timer_timeout"))

func show_level(level: int, pos: Vector2):
	levels.position = pos
	levels.frame = level
	levels.visible = true
	levels_anim.stop()
	levels_anim.play("show_effect")
	levels_timer.start(0.8) # 0.8秒后隐藏

func _on_levels_timer_timeout():
	levels.visible = false
