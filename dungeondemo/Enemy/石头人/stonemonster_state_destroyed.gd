class_name StoneMonsterStateDestroy extends EnemyState

@export var died_sound: AudioStream
@export var anim_name: String = "die"
@export var knockback_speed: float = 300.0
@export var decelerate_speed: float = 10.0
@onready var audio: AudioStreamPlayer2D = $"../../AudioStreamPlayer2D"
@onready var animated_sprite_2d: AnimatedSprite2D = $"../../AnimatedSprite2D"

@export_category("AI")

var _damage_position:Vector2
var _direction: Vector2

func Init() -> void:
	enemy.enemy_destroyed.connect(OnEnemyDestroyed)

func Enter() -> void:
	enemy.invulnerable = true

	# **确保敌人 HP <= 0 才进入销毁状态**
	if enemy.hp > 0:
		return

	# **获取朝向方向（面向玩家）**
	if enemy.player:
		_direction = enemy.global_position.direction_to(_damage_position)
	else:
		_direction = Vector2.ZERO  # 没有玩家则不改变方向


	# 播放死亡动画
	animated_sprite_2d.play("hurt")

	# **确保信号只连接一次，防止重复触发**
	if not enemy.enemy_animated.animation_finished.is_connected(OnAnimationFinished):
		enemy.enemy_animated.animation_finished.connect(OnAnimationFinished)

	# 播放死亡音效
	if died_sound:
		audio.stream = died_sound
		audio.pitch_scale = randf_range(0.9, 1.1)
		audio.play()

func Exit() -> void:
	# **解除绑定，防止重复调用**
	if enemy.enemy_animated.animation_finished.is_connected(OnAnimationFinished):
		enemy.enemy_animated.animation_finished.disconnect(OnAnimationFinished)

func Process(_delta: float) -> EnemyState:
	# **减速击退效果**
	enemy.velocity -= enemy.velocity * decelerate_speed * _delta
	return null

func Physics(_delta: float) -> EnemyState:
	return null

func OnEnemyDestroyed(hurt_box:HurtBox) -> void:
	# **确保敌人真正死亡后才进入此状态**
	if enemy.hp <= 0:
		_damage_position=hurt_box.global_position
		state_machine.ChangeState(self)

# **动画播放完后删除敌人**
func OnAnimationFinished() -> void:
	if enemy.hp <= 0:
		enemy.queue_free()
