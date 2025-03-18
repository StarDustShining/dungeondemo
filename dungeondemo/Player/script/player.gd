class_name Player extends CharacterBody2D

signal DirectionChanged(new_direction:Vector2)
signal player_damaged( hurt_box: HurtBox )

const PLAYER_HUD = preload("res://GUI/player_hud/PlayerHud.tscn")

var cardinal_direction: Vector2 = Vector2.DOWN
var direction: Vector2 = Vector2.ZERO

var invulnerable:bool=false
var hp:int =6
var max_hp:int=6

var attack : int = 1 :
	set( v ):
		attack = v
		#update_damage_values()

var defense : int = 0
var defense_bonus : int = 0


@onready var player_animated: AnimatedSprite2D = $Player
@onready var state_machine: PlayerStateMachine = $StateMachine
@onready var hit_box: HitBox = $HitBox


func _ready():
	PlayerManager.player=self
	state_machine.Initialize(self)
	hit_box.damaged.connect(TakeDamage)
	UpdateHp(99)
	#update_damage_values()
	pass

func _process(_delta):
	direction.x = Input.get_action_strength("右") - Input.get_action_strength("左")
	direction.y = Input.get_action_strength("下") - Input.get_action_strength("上")

	if direction.length() > 1:
		direction = direction.normalized()  # 归一化方向，防止斜向移动变快

	#SetDirection()  # 检测并更新方向
	pass

func _physics_process(_delta):
	move_and_slide()
	
func _exit_tree():
	var time_str = Time.get_ticks_msec()  # 获取当前时间（毫秒）
	print("Player 已被移除，时间戳:", time_str, " ms")

	# 打印调用栈，看看是从哪里调用了 queue_free()
	print("调用栈信息:")
	print_stack()


func SetDirection() -> bool:
	var new_dir: Vector2 = Vector2.ZERO
	if direction == Vector2.ZERO:
		return false

	# 根据方向的 x 和 y 值决定新的方向
	if direction.x < 0:
		new_dir.x = -1  # 向左
	elif direction.x > 0:
		new_dir.x = 1   # 向右

	if direction.y < 0:
		new_dir.y = -1  # 向上
	elif direction.y > 0:
		new_dir.y = 1   # 向下

	# 根据新方向设置 cardinal_direction
	if new_dir != Vector2.ZERO:
		if new_dir.x == -1 and new_dir.y == -1:
			new_dir = Vector2(-1, -1)  # 左上
		elif new_dir.x == -1 and new_dir.y == 1:
			new_dir = Vector2(-1, 1)  # 左下
		elif new_dir.x == 1 and new_dir.y == -1:
			new_dir = Vector2(1, -1)  # 右上
		elif new_dir.x == 1 and new_dir.y == 1:
			new_dir = Vector2(1, 1)  # 右下

	if new_dir == cardinal_direction:
		return false

	cardinal_direction = new_dir
	DirectionChanged.emit(new_dir)
	return true

func UpdateAnimation(state: String) -> void:
	player_animated.play(state + "_" + AnimDirection())

func AnimDirection() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "Down"
	elif cardinal_direction == Vector2.UP:
		return "Up"
	elif cardinal_direction == Vector2.LEFT:
		return "Left"
	elif cardinal_direction == Vector2.RIGHT:
		return "Right"
	elif cardinal_direction == Vector2(-1, -1):
		return "Left_Up"  # 左上
	elif cardinal_direction == Vector2(-1, 1):
		return "Left_Down"  # 左下
	elif cardinal_direction == Vector2(1, -1):
		return "Right_Up"  # 右上
	else:
		return "Right_Down"  # 默认返回值

func TakeDamage( hurt_box : HurtBox ) -> void:
	if invulnerable == true:
		return
	
	if hp > 0:
		var dmg : int = hurt_box.damage
		
		# Simple damage calculation that subtracts defense value
		# will keep damage to a minimum of 1, so we will do an if check
		# to allow 0 to still be passed by a hurt_box if needed
		if dmg > 0:
			dmg = clampi( dmg - defense - defense_bonus, 1, dmg )
			print("hp:")
			print(hp)
		UpdateHp( -dmg )
		player_damaged.emit( hurt_box )
	
	pass

func UpdateHp( delta : int ) -> void:
	hp = clampi( hp + delta, 0, max_hp )
	PlayerHud.UpdateHp( hp, max_hp )
	pass

func MakeInvulnerable( _duration : float = 1.0 ) -> void:
	invulnerable = true
	hit_box.monitoring = false
	await get_tree().create_timer( _duration ).timeout
	invulnerable = false
	hit_box.monitoring = true
	pass

#func update_damage_values() -> void:
	#var damage_value : int = attack + PlayerManager.INVENTORY_DATA.get_attack_bonus()
	#%AttackHurtBox.damage = damage_value
	#%ChargeSpinHurtBox.damage = damage_value * 2
