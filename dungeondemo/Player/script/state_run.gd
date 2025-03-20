class_name State_Run extends State

@export var run_speed: float = 350  # 跑步速度（比 walk 快）
@export var attack_sound:AudioStream

@onready var walk: State = $"../Walk"
@onready var idle: State = $"../Idle"
@onready var attack_spear: State = $"../Attack_Spear"
@onready var audio: AudioStreamPlayer2D = $"../../Audio/AudioStreamPlayer2D"

func Enter() -> void:
	player.UpdateAnimation("run")  # 播放跑步动画
	audio.stream=attack_sound
	audio.pitch_scale=randf_range(0.9,1.1)
	audio.stream.loop = true
	audio.play()

func Exit() -> void:
	audio.stop()  # 停止音频播放
	pass

func Process(_delta: float) -> State:
	if not Input.is_action_pressed("shift"):  # 松开 Shift
		if player.direction == Vector2.ZERO:
			return idle  # 停止移动则切换回 Idle
		return walk  # 继续移动则切换回 Walk
	player.velocity = player.direction.normalized() * run_speed  # 更新速度
	player.SetDirection()  # 更新方向
	player.UpdateAnimation("run")
	return null

func Physics(_delta: float) -> State:
	return null

func HandleInput(_event:InputEvent)->State:
	if _event.get_action_strength("攻击"):
		return attack_spear
	if _event.is_action_pressed("交互"):
		PlayerManager.interact()
	return null
