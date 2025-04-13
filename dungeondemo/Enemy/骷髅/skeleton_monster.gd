class_name SkeletonMonster extends Enemy


const DIR_6=[Vector2.RIGHT,Vector2.LEFT,Vector2(-1, -1),Vector2(-1, 1),Vector2(1, -1),Vector2(1, 1)]

func _ready() -> void:
	state_machine.Initialize(self)
	player=PlayerManager.player
	hit_box.damaged.connect(TakeDamage)
	pass

func _process(_delta):
	pass


func _physics_process(_delta):
	move_and_slide()
	
func SetDirection(_new_direction: Vector2) -> bool:
	direction = _new_direction
	if direction == Vector2.ZERO:
		return false

	var best_match = DIR_6[0]  # 假设第一个方向最接近
	var best_angle = PI  # 夹角最大值设为 180°（PI 弧度）

	# 遍历所有方向，找到夹角最小的方向
	for dir in DIR_6:
		var angle = direction.angle_to(dir)  # 计算夹角
		if abs(angle) < best_angle:
			best_angle = abs(angle)
			best_match = dir

	if best_match == cardinal_direction:
		return false  # 方向没变，不需要更新

	cardinal_direction = best_match
	direction_changed.emit(best_match)
	return true

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
