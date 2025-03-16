class_name EnemyStateIdle extends EnemyState

@export var anim_name:String="idle"

@export_category("AI")
@export var state_duration_min:float=0.5
@export var state_duration_max:float=1.5
@export var after_idle_state:EnemyState


var _timer:float=0.0

func Init()->void:
	
	pass


func Enter()->void:
	enemy.velocity=Vector2.ZERO
	_timer=randf_range(state_duration_min,state_duration_max)
	enemy.UpdateAnimation("idle")
	pass

func Exit()->void:
	pass

func Process(_delta:float)->EnemyState:
	_timer -=_delta
	if _timer<=0:
		return after_idle_state
	return null
	
func Physics(_delta:float)->EnemyState:
	return null
