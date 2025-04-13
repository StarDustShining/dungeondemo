class_name StoneMonsterStateHurt extends EnemyState

@export var hurt_sound: AudioStream
@export var anim_name: String = "hurt"
@export var knockback_speed: float = 400.0  # 修正变量名
@export var decelerate_speed: float = 10.0
@onready var audio: AudioStreamPlayer2D = $"../../AudioStreamPlayer2D"
@onready var animated_sprite_2d: AnimatedSprite2D = $"../../AnimatedSprite2D"


@export_category("AI")
@export var next_state: EnemyState

var _damage_position:Vector2
var _direction: Vector2
var _animation_finished: bool = false

func Init() -> void:
	enemy.enemy_damaged.connect(OnEnemyDamaged)
	pass

func Enter() -> void:
	print("敌人收到伤害")
	#enemy.invulnerable = true
	_animation_finished = false

	# 播放受击动画
	animated_sprite_2d.play("hurt")
	if not animated_sprite_2d.animation_finished.is_connected(OnAnimationFinished):
		animated_sprite_2d.animation_finished.connect(OnAnimationFinished)

	# 播放受击音效
	audio.stream = hurt_sound
	audio.pitch_scale = randf_range(0.9, 1.1)
	audio.play()
	pass

func Exit() -> void:
	enemy.invulnerable=false
	enemy.enemy_animated.animation_finished.disconnect(OnAnimationFinished)
	pass

func Process(_delta: float) -> EnemyState:
	if _animation_finished:
		return next_state

	# 减速击退效果
	enemy.velocity -= enemy.velocity * decelerate_speed * _delta
	return null

func Physics(_delta: float) -> EnemyState:
	return null

func OnEnemyDamaged(hurt_box:HurtBox) -> void:
	_damage_position=hurt_box.global_position
	state_machine.ChangeState(self)

func OnAnimationFinished()->void:
	_animation_finished=true
