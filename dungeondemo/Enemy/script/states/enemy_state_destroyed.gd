class_name EnemyStateDestroy extends EnemyState

const PICKUP = preload("res://Items/item_pickup/ItemPickup.tscn")

@export var attack_sound: AudioStream
@export var anim_name: String = "die"
@export var knockback_speed: float = 300.0
@export var decelerate_speed: float = 10.0
@export var drops : Array[ DropData ]
@onready var audio: AudioStreamPlayer2D = $"../../AudioStreamPlayer2D"

@export_category("AI")
@export_category("Item Drops")


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

	enemy.SetDirection(_direction)  # **敌人朝向玩家**
	enemy.velocity = -_direction * knockback_speed  # **击退方向是远离玩家**

	# 播放死亡动画
	enemy.UpdateAnimation(anim_name)

	# **确保信号只连接一次，防止重复触发**
	if not enemy.enemy_animated.animation_finished.is_connected(OnAnimationFinished):
		enemy.enemy_animated.animation_finished.connect(OnAnimationFinished)

	# 播放死亡音效
	if attack_sound:
		audio.stream = attack_sound
		audio.pitch_scale = randf_range(0.9, 1.1)
		audio.play()
		
	drop_items()

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

func disable_hurt_box() -> void:
	var hurt_box : HurtBox = enemy.get_node_or_null("HurtBox")
	if hurt_box:
		hurt_box.monitoring = false

func drop_items() -> void:
	if drops.size() == 0:
		return
	
	for i in drops.size():
		if drops[ i ] == null or drops[ i ].item == null:
			continue
		var drop_count : int = drops[ i ].get_drop_count()
		for j in drop_count:
			var drop : ItemPickup = PICKUP.instantiate() as ItemPickup
			drop.item_data = drops[ i ].item
			enemy.get_parent().call_deferred( "add_child", drop )
			drop.global_position = enemy.global_position
	pass
