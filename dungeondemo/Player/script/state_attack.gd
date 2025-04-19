class_name State_Attack_Spear extends State

var attacking:bool=false

@export var attack_sound:AudioStream
@export_range(1,20,0.5) var decelerate_speed:float=1.0

@onready var walk: State = $"../Walk"
@onready var run: State = $"../Run"
@onready var idle: State = $"../Idle"
@onready var audio: AudioStreamPlayer2D = $"../../Audio/AudioStreamPlayer2D"
@onready var hurt_box: HurtBox = $"../../Interaction/AttackHurtBox"


##告诉在进入这个状态时发生了什么
func Enter()->void:
	player.UpdateAnimation("attack_Spear")
	player.player_animated.animation_finished.connect( EndAttack )
	audio.stream=attack_sound
	audio.pitch_scale=randf_range(0.9,1.1)
	audio.play()
	
	attacking=true
	
	await get_tree().create_timer(0.075).timeout
	hurt_box.monitoring = true
	pass
	
func Exit()->void:
	player.player_animated.animation_finished.disconnect( EndAttack )
	attacking=false
	hurt_box.monitoring=false
	pass

func Process(_delta:float)->State:
	player.velocity-=player.velocity*decelerate_speed*_delta
	if attacking==false:
		if player.direction==Vector2.ZERO:
			return idle
		else:
			return walk
	return null

func Physics(_delta:float)->State:
	return null
	
func HandleInput(_event:InputEvent)->State:
	return null

func EndAttack()->void:
	attacking = false
