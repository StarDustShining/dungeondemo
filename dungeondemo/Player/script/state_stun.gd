class_name State_Stun extends State

@export var knockback_speed : float = 800.0
@export var decelerate_speed : float = 10.0
@export var invulnerable_duration : float = 1.0
@export var stun_duration: float = 1.0  # 让stun最多持1s

var hurt_box : HurtBox
var direction : Vector2
var stun_timer: float = 0.0  # 记录stun时间
var _damage_position:Vector2
var next_state : State = null

@onready var walk: State = $"../Walk"
@onready var idle: State = $"../Idle"
@onready var death: State = $"../Death"



func Init() -> void:
	player.player_damaged.connect(PlayerDamaged)

## 进入 Stun 状态
func Enter() -> void:
	print("玩家进入 stun 状态")
	player.UpdateAnimation("stun")
	player.player_animated.animation_finished.connect(AnimationFinished)

	direction = player.global_position.direction_to( _damage_position )
	player.velocity = direction * -knockback_speed
	player.SetDirection()
	
	player.MakeInvulnerable(invulnerable_duration)
	
## 退出 Stun 状态
func Exit() -> void:
	player.player_animated.animation_finished.disconnect(AnimationFinished)
	next_state = null
	pass

## 处理 _process 更新
func Process(_delta: float) -> State:
	stun_timer += _delta  # 更新计时器
	player.velocity -= player.velocity * decelerate_speed * _delta  # 速度逐渐降低

	# **如果计时器超过 stun 持续时间，切换到 idle**
	if stun_timer >= stun_duration:
		print("Stun 持续时间结束，切换到 idle")
		return idle
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
	if state_machine.current_state == self:
		return
	if state_machine.current_state != death:
		state_machine.ChangeState(self)
	

## 动画完成回调
func AnimationFinished(_a: String) -> void:
	next_state=null
	if player.hp <= 0:
		next_state = death
