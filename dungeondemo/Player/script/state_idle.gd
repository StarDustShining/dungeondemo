class_name State_Idle extends State

@onready var walk: State = $"../Walk"
@onready var run: State = $"../Run"
@onready var attack_spear: State = $"../Attack_Spear"

##告诉在进入这个状态时发生了什么
func Enter()->void:
	player.UpdateAnimation("idle")
	pass
	
func Exit()->void:
	pass

func Process(_delta:float)->State:
	if player.direction!=Vector2.ZERO:
		return walk
	player.velocity=Vector2.ZERO
	return null

func Physics(_delta:float)->State:
	return null
	
func HandleInput(_event:InputEvent)->State:
	if _event.get_action_strength("shift"):
		return run
	if _event.get_action_strength("攻击"):
		return attack_spear
	if _event.is_action_pressed("交互"):
		PlayerManager.interact()
	return null
