class_name StoneMonster extends Enemy

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	state_machine.Initialize(self)
	player=PlayerManager.player
	hit_box.damaged.connect(TakeDamage)
	pass

func _physics_process(_delta):
	move_and_slide()
	
func UpdateAnimation(state: String) -> void:
	enemy_animated.play(state)

func TakeDamage(hurt_box:HurtBox)->void:
	if invulnerable==true:
		return
	hp-=hurt_box.damage
	
	if hp>0:
		enemy_damaged.emit(hurt_box)
	else:
		enemy_destroyed.emit(hurt_box)
