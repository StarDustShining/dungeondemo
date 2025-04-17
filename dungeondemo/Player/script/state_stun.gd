class_name State_Stun extends State

@export var knockback_speed: float = 200.0	# 增加击退速度
@export var decelerate_speed: float = 3	# 降低速度衰减系数，使击退更远
@export var invulnerable_duration: float = 0.5	# 无敌时间
@export var stun_duration: float = 0.5	# 击晕持续时间
@export var stun_sound:AudioStream

var hurt_box: HurtBox	# 伤害来源
var direction: Vector2	# 击退方向
var stun_timer: float = 0.0	# 击晕计时器
var _damage_position: Vector2	# 伤害位置
var next_state : State = null

@onready var walk: State = $"../Walk"
@onready var idle: State = $"../Idle"
@onready var death: State = $"../Death"
@onready var audio: AudioStreamPlayer2D = $"../../Audio/AudioStreamPlayer2D"

## 初始化
func Init() -> void:
	player.player_damaged.connect(PlayerDamaged)

## 进入击晕状态
func Enter() -> void:
	print("玩家进入 stun 状态")
	player.player_animated.animation_finished.connect(AnimationFinished)
	audio.stream=stun_sound
	audio.pitch_scale=randf_range(0.9,1.1)
	audio.play()
	# 计算击退方向（从玩家指向伤害来源，然后取反）
	direction = player.global_position.direction_to(_damage_position)
	player.velocity = -direction * knockback_speed	# 取反，确保击退方向正确
	player.SetDirection()
	player.UpdateAnimation("stun")
	player.effect_animation_player.play("damage")
	# 设置无敌时间
	player.MakeInvulnerable(invulnerable_duration)

	# 重置计时器
	stun_timer = 0.0

## 退出击晕状态
func Exit() -> void:
	player.player_animated.animation_finished.disconnect(AnimationFinished)
	next_state = null

## 处理 _process 更新
func Process(_delta: float) -> State:
	stun_timer += _delta	# 更新计时器

	# 速度逐渐降低
	player.velocity -= player.velocity * decelerate_speed * _delta

	# 如果计时器超过击晕持续时间，切换到 idle
	if stun_timer >= stun_duration&&player.hp > 0:
		print("Stun 持续时间结束，切换到 idle")
		return idle
	elif player.hp <= 0:
		print("Stun 持续时间结束，切换到 death")
		return death
	return next_state

## 处理 _physics_process 更新
func Physics(_delta: float) -> State:
	return null

## 处理输入事件
func HandleInput(_event: InputEvent) -> State:
	return null

## 处理玩家受伤
func PlayerDamaged(_hurt_box: HurtBox) -> void:
	hurt_box = _hurt_box
	_damage_position = hurt_box.global_position
	if state_machine.current_state == self:
		return

	# 如果玩家已经死亡，不再切换到 stun 状态
	if state_machine.current_state == death:
		state_machine.ChangeState(death)
	# 切换到 stun 状态
	state_machine.ChangeState(self)

## 动画完成回调
func AnimationFinished(_a: String) -> void:
	next_state = null
	if player.hp <= 0:
		next_state = death
