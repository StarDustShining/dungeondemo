class_name State_Track extends EnemyState

@export var track_speed: float = 50  # 追踪速度
@onready var idle: EnemyStateIdle = $"../Idle"  # 闲置状态的引用
@onready var attack: State_Attack = $"../Attack"
@onready var wander: EnemyStateWander = $"../Wander"  # 游荡状态的引用

func Enter() -> void:
	# 进入追踪状态时播放追踪动画
	enemy.UpdateAnimation("walk")

func Exit() -> void:
	# 退出追踪状态的逻辑
	pass

func Process(_delta: float) -> EnemyState:
	# 计算敌人与玩家之间的距离
	if enemy.player:
		var distance_to_player = enemy.global_position.distance_to(enemy.player.global_position)
		
		if distance_to_player <= enemy.attack_distance:
			# 距离足够近，切换到攻击状态
			return attack
		elif distance_to_player > enemy.track_distance:
			# 超出追踪距离，切换回游荡状态
			return wander
		else:
			# 在追踪范围内，继续追踪玩家
			TrackPlayer(_delta)
			return null

	return idle  # 如果没有玩家，则返回闲置状态

func TrackPlayer(_delta: float) -> void:
	if enemy.player:
		# 计算指向玩家的方向并更新速度
		var direction = enemy.player.global_position - enemy.global_position
		enemy.SetDirection(direction)
		enemy.velocity = direction.normalized() * track_speed  # 更新敌人的速度
		if direction.x<0:
			enemy.enemy_animated.play("walk_Left")
		else :
			enemy.enemy_animated.play("walk_Right")
		# 更新敌人的位置
		enemy.global_position += enemy.velocity * _delta  # 使用直接位置更新的方法\
	

func Physics(_delta: float) -> EnemyState:
	return null  # 物理更新逻辑可以在需要时实现

func HandleInput(_event: InputEvent) -> EnemyState:
	return null  # 处理输入逻辑（如果需要）
