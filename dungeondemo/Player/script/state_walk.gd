class_name State_Walk extends State

@export var move_speed:float=200
@export var attack_sound:AudioStream

@onready var idle: State = $"../Idle"
@onready var run: State= $"../Run"
@onready var attack_spear: State = $"../Attack_Spear"
@onready var audio: AudioStreamPlayer2D = $"../../Audio/AudioStreamPlayer2D"

##告诉在进入这个状态时发生了什么
func Enter()->void:
	player.UpdateAnimation("walk")
	audio.stream=attack_sound
	audio.pitch_scale=randf_range(0.9,1.1)
	audio.stream.loop = true
	audio.play()  # 播放音频
	pass
	
func Exit()->void:
	audio.stop()  # 停止音频播放
	pass
	
func Process(_delta: float) -> State:
	if player.direction == Vector2.ZERO:
		return idle  # 如果没有输入，切换到待机状态
	player.velocity = player.direction.normalized() * move_speed  # 更新速度
	if player.SetDirection():  # 更新方向
		player.UpdateAnimation("walk")
	return null  # 保持当前状态

	
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
