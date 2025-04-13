class_name StoneMonsterStateAttack extends EnemyState

@export var anim_name: String = "attack"
@export var attack_sound: AudioStream
@export_range(0.1, 2.0, 0.05) var attack_duration: float = 1.0  # 攻击持续时间
@export var knockback_speed: float = 300.0  # 击退速度
@export var cooldown_time: float = 1.5  # 攻击冷却时间
@export var attack_distance: float=200

var attacking: bool = false
var on_cooldown: bool = false  # 记录敌人是否在冷却中

@onready var audio: AudioStreamPlayer2D = $"../../AudioStreamPlayer2D"
@onready var hurt_box: HurtBox = $"../../HurtBox"
@onready var animated_sprite_2d: AnimatedSprite2D = $"../../AnimatedSprite2D"
@onready var idle: StoneMonsterStateIdle = $"../Idle"

func Enter() -> void:
	if on_cooldown:
		return

	attacking = true
	hurt_box.monitoring = true  # 确保攻击开始时开启监控

	# 计算方向并播放相应动画
	var direction = enemy.player.global_position - enemy.global_position
	animated_sprite_2d.play("attack")
	enemy.velocity = Vector2.ZERO

	# 播放攻击音效
	audio.stream = attack_sound
	audio.pitch_scale = randf_range(0.9, 1.1)
	audio.play()

	# 攻击持续一段时间
	await get_tree().create_timer(attack_duration).timeout
	
	# 结束攻击，进入冷却状态
	EndAttack()

func Exit() -> void:
	attacking = false
	hurt_box.monitoring = false  # 关闭 hurt_box 的监控

func Process(_delta: float) -> EnemyState:
	if not attacking:
		var distance_to_player = enemy.global_position.distance_to(enemy.player.global_position)
		if distance_to_player >= attack_distance:
			return idle  # 切换到追踪状态
	return null
	
func Physics(_delta: float) -> EnemyState:
	return null  # 物理更新可以在需要时实现

func HandleInput(_event: InputEvent) -> EnemyState:
	return null  # 处理输入逻辑（如果需要）

func EndAttack() -> void:
	attacking = false
	hurt_box.monitoring = false  # 关闭 hurt_box 的监控
	on_cooldown = true  # 开启冷却
	await get_tree().create_timer(cooldown_time).timeout
	on_cooldown = false  # 冷却结束，可以再次攻击
	hurt_box.monitoring = true  # 确保攻击开始时开启监控
