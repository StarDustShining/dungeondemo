class_name State extends Node

static var player: Player
static var state_machine:PlayerStateMachine

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func Init()->void:
	pass


##告诉在进入这个状态时发生了什么
func Enter()->void:
	pass
	
func Exit()->void:
	pass
	
func Process(_delta:float)->State:
	return null
	
func Physics(_delta:float)->State:
	return null
	
func HandleInput(_event:InputEvent)->State:
	return null
