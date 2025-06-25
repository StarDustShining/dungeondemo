extends Sprite2D

@export var fall_speed: float = 10

var init_y_pos: float = -32

# true if falling key has passed the allowed input frame
var has_passed: bool = false
var pass_threshold = 536.0

func _init():
	set_process(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position += Vector2(0, fall_speed)
	
	# Find out how long it takes for arrow to reach critical spot
	if global_position.y > pass_threshold and not $Timer.is_stopped():
		print($Timer.wait_time - $Timer.time_left)
		$Timer.stop()
		has_passed = true

func Setup(target_x: float, target_frame: int):
	global_position = Vector2(target_x, init_y_pos)
	frame = target_frame
	
	set_process(true)
	


func _on_destroy_timer_timeout():
	queue_free()
