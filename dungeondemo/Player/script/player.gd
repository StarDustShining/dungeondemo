class_name Player extends CharacterBody2D

signal DirectionChanged(new_direction:Vector2)
signal player_damaged( hurt_box: HurtBox )

const PLAYER_HUD = preload("res://GUI/player_hud/PlayerHud.tscn")

var cardinal_direction: Vector2 = Vector2.DOWN
var direction: Vector2 = Vector2.ZERO

var invulnerable:bool=false
var hp:int =10
var max_hp:int=10

var attack : int = 1 :
	set( v ):
		attack = v
		#update_damage_values()

var defense : int = 0
var defense_bonus : int = 0

var box_control: bool = false
var pushed_box: CharacterBody2D = null
var pulling: bool = false

# 添加标志变量
var in_special_level: bool = false

@onready var player_animated: AnimatedSprite2D = $Player
@onready var state_machine: PlayerStateMachine = $StateMachine
@onready var hit_box: HitBox = $HitBox
@onready var effect_animation_player: AnimationPlayer = $EffectAnimationPlayer
@onready var interaction_icon: AnimatedSprite2D = $InteractionIcon
@onready var interact_area: Area2D = $Interaction/InteractArea


func _ready():
	PlayerManager.player=self
	state_machine.Initialize(self)
	hit_box.damaged.connect(TakeDamage)
	interaction_icon.visible=false
	UpdateHp(99)
	#update_damage_values()
	pass

func _physics_process(_delta):
	player_move(_delta)
	player_raycast()

func _exit_tree():
	var time_str = Time.get_ticks_msec()  # 获取当前时间（毫秒）

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
		if dmg > 0:
			dmg = clampi( dmg - defense - defense_bonus, 1, dmg )
		UpdateHp( -dmg )
		player_damaged.emit( hurt_box )
	print("hp:")
	print(hp)
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

func OnAreaEnter(_a: Area2D) -> void:
	if _a.name == "E":
		interaction_icon.visible = true
		interaction_icon.play("E")
	elif _a.name == "Q&R":
		interaction_icon.visible = true
		interaction_icon.play("Q&R")
	elif _a.name == "Space":
		interaction_icon.visible = true
		interaction_icon.play("Space")
	else:
		interaction_icon.visible = true
		interaction_icon.play("Default")  # 使用默认动画名称

func OnAreaExit(_a: Area2D) -> void:
	interaction_icon.visible=false

func player_move(_delta):
	direction.x = Input.get_action_strength("右") - Input.get_action_strength("左")
	direction.y = Input.get_action_strength("下") - Input.get_action_strength("上")

	if direction.length() > 1:
		direction = direction.normalized()  # 归一化方向，防止斜向移动变快

	if not box_control:
		pass
	else:
		velocity.x = 0
		velocity.y = 0

	move_and_slide()
	player_raycast()
		
func player_raycast():
	var raycast = $Interaction/RayCast2D
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider.is_in_group("PushItem"):
			if Input.is_action_pressed("推拉物品"):
				start_push(collider)
			elif box_control and pushed_box == collider:
				# 如果松开键但还在推
				stop_push()
	else:
		stop_push()

	if box_control and pushed_box:
		handle_push_movement()

func start_push(box: CharacterBody2D):
	# 确保箱子有Sprite2D子节点
	var sprite = box.get_node("Sprite2D")  # 假设箱子的Sprite2D节点名称为Sprite2D
	if sprite:
		sprite.modulate = Color(247 / 255.0, 206 / 255.0, 0 / 255.0,0.8)
	box_control = true
	pushed_box = box

func stop_push():
	# 不再给玩家加颜色特效，直接去除箱子的颜色特效
	if pushed_box:
		var sprite = pushed_box.get_node("Sprite2D")  # 获取Sprite2D子节点
		if sprite:
			sprite.modulate = Color(1, 1, 1)  # 还原箱子的颜色为白色
	box_control = false
	if pushed_box:
		pushed_box.velocity = Vector2.ZERO
	pushed_box = null

func handle_push_movement():
	var move_vec = Vector2.ZERO
	if Input.is_action_pressed("左"):
		move_vec.x = -1
	elif Input.is_action_pressed("右"):
		move_vec.x = 1
	elif Input.is_action_pressed("上"):
		move_vec.y = -1
	elif Input.is_action_pressed("下"):
		move_vec.y = 1

	pushed_box.velocity = move_vec.normalized() * 50

func set_special_level(flag: bool):
	in_special_level = flag

func revive_player() -> void:
	UpdateHp( 99 )
	state_machine.change_state( $StateMachine/Idle )
