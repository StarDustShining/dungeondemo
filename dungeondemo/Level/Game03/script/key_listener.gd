extends Sprite2D

@onready var falling_key = preload("res://Level/Game03/FallingKey.tscn")
@export var key_name: String = ""
@onready var level: Control = $Level

var falling_key_queue = []

# If distance_from_pass is less than threshold, give that score
var perfect_press_threshold: float = 30
var great_press_threshold: float = 60
var ok_press_threshold: float = 90
# otherwise, miss

var perfect_press_score: float = 200
var great_press_score: float = 100
var ok_press_score: float = 50

func _ready():
	$GlowOverlay.frame = frame -6
	MusicGameSignals.CreateFallingKey.connect(CreateFallingKey)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if falling_key_queue.size() > 0:
		if falling_key_queue.front().has_passed:
			falling_key_queue.pop_front()
			MusicGameSignals.ResetCombo.emit()
			
		if Input.is_action_just_pressed(key_name):
			var key_to_pop = falling_key_queue.pop_front()
			if key_to_pop != null:  # Check if key_to_pop is not null
				var distance_from_pass = abs(key_to_pop.pass_threshold - key_to_pop.global_position.y)
				
				$AnimationPlayer.stop()
				$AnimationPlayer.play("key_hit")
				
				var show_pos = Vector2(global_position.x, global_position.y + 120) # 字母下方
				
				if distance_from_pass < perfect_press_threshold:
					MusicGameSignals.IncrementScore.emit(perfect_press_score)
					MusicGameSignals.IncrementCombo.emit()
					level.show_level(0, show_pos)
				elif distance_from_pass < great_press_threshold:
					MusicGameSignals.IncrementScore.emit(great_press_score)
					MusicGameSignals.IncrementCombo.emit()
					level.show_level(1, show_pos)
				elif distance_from_pass < ok_press_threshold:
					MusicGameSignals.IncrementScore.emit(ok_press_score)
					MusicGameSignals.IncrementCombo.emit()
					level.show_level(2, show_pos)
				else:
					level.show_level(3, show_pos)
					MusicGameSignals.ResetCombo.emit()
				key_to_pop.queue_free()
			else:
				print("Error: key_to_pop is null!")
		pass

# Function to create a falling key and add it to the queue
func CreateFallingKey():
	var fk_inst = falling_key.instantiate()
	get_tree().get_root().call_deferred("add_child", fk_inst)
	fk_inst.Setup(position.x, frame -12)  # Ensure Setup properly initializes pass_threshold
	falling_key_queue.push_back(fk_inst)
