class_name EnemyStateWander extends EnemyState

@export var anim_name: String = "walk"
@export var wander_speed: float = 50.0

@export_category("AI")
@export var state_animation_duration: float = 0.5
@export var state_cycles_min: int = 1
@export var state_cycles_max: int = 3
@export var next_state:EnemyState

@onready var track: State_Track = $"../Track"

var _timer: float = 0.0
var _direction: Vector2

func Init() -> void:
	pass

func Enter() -> void:
	_timer = randf_range(state_cycles_min, state_cycles_max) * state_animation_duration

	var rand = randi_range(0, enemy.DIR_6.size() - 1)  # 随机选择 0~5 之间的索引
	_direction = enemy.DIR_6[rand]  # 选取随机方向

	enemy.velocity = _direction.normalized() * wander_speed
	
	enemy.SetDirection(_direction)
	enemy.UpdateAnimation(anim_name)

	pass

func Exit() -> void:
	pass

func Process(_delta: float) -> EnemyState:
	_timer -= _delta
	if _timer <= 0:
		return next_state  # 切换到下一个状态

	if enemy.player:
		# 计算敌人与玩家之间的距离
		var distance_to_player = enemy.global_position.distance_to(enemy.player.global_position)
		
		if distance_to_player <= enemy.track_distance:
			return track  # 切换到追踪状态

	return null
	
func Physics(_delta: float) -> EnemyState:
	return null
