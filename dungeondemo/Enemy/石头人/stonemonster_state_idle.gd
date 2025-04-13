class_name StoneMonsterStateIdle extends EnemyState

@export var anim_name:String="idle"

@export_category("AI")
@export var state_duration_min:float=0.5
@export var state_duration_max:float=1.5
@export var after_idle_state:EnemyState
@export var attack_distance: float=200

@onready var attack: StoneMonsterStateAttack = $"../Attack"
@onready var animated_sprite_2d: AnimatedSprite2D = $"../../AnimatedSprite2D"


var _timer:float=0.0

func Enter()->void:
	enemy.velocity=Vector2.ZERO
	_timer=randf_range(state_duration_min,state_duration_max)
	animated_sprite_2d.play("idle")
	pass

func Exit()->void:
	pass

func Process(_delta:float)->EnemyState:
	var distance_to_player = enemy.global_position.distance_to(enemy.player.global_position)
	if distance_to_player <= attack_distance:
		return attack  # 切换到追踪状态
	return null
	
func Physics(_delta:float)->EnemyState:
	return null
