class_name Enemy extends CharacterBody2D

signal direction_changed(new_direction:Vector2)
signal enemy_damaged(hurt_box:HurtBox)
signal enemy_destroyed(hurt_box:HurtBox)

@export var hp:int=3

var cardinal_direction: Vector2 = Vector2.LEFT
var direction: Vector2 = Vector2.ZERO
var player:Player
var invulnerable:bool=false
var attack_distance: float = 100 # 攻击距离
var track_distance: float = 350

@onready var enemy_animated: AnimatedSprite2D = $AnimatedSprite2D
@onready var hit_box:HitBox=$HitBox
@onready var state_machine:EnemyStateMachine=$EnemyStateMachine

func _ready() -> void:
	state_machine.Initialize(self)
	player=PlayerManager.player
	hit_box.damaged.connect(TakeDamage)
	pass

func _process(_delta):
	pass


func _physics_process(_delta):
	move_and_slide()
	
	
func UpdateAnimation(state: String) -> void:
	enemy_animated.play(state + "_" + AnimDirection())

func AnimDirection() -> String:
	if cardinal_direction.x < 0:  
		return "Left"  
	return "Right"

func TakeDamage(hurt_box:HurtBox)->void:
	if invulnerable==true:
		return
	hp-=hurt_box.damage
	
	if hp>0:
		enemy_damaged.emit(hurt_box)
	else:
		enemy_destroyed.emit(hurt_box)
