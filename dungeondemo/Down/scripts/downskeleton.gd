extends CharacterBody2D

signal direction_changed(new_direction:Vector2)

@export var speed = 100  # 移动速度
@export var chase_speed_multiplier = 1.5  # 追击时的速度倍数
@export var damage = 0.5  # 对玩家造成的伤害

@onready var animation_player = $AnimationPlayer
@onready var wander = $Wander
@onready var area_2d = $Area2D
@onready var hurt_box: HurtBox = $HurtBox


var is_chasing = false
var player = null
var is_stunned = false  # 是否被击晕
var stun_timer = 0.0    # 击晕计时器


# 预加载音效资源
var attack_sound = preload("res://Player/spear_attack.mp3") if ResourceLoader.exists("res://Player/spear_attack.mp3") else null
var stun_sound = preload("res://Player/stun.mp3") if ResourceLoader.exists("res://Player/stun.mp3") else null

func _ready():
	# 设置Wander节点的参数
	wander.speed = speed

	# 开始时播放向下走动画
	animation_player.play("walk_down")

func _physics_process(delta):
	# 处理击晕状态
	if is_stunned:
		stun_timer -= delta
		if stun_timer <= 0:
			is_stunned = false
			# 恢复移动
			if is_chasing:
				animation_player.play("walk_down")  # 根据方向可能需要调整
		return  # 如果被击晕，不执行下面的移动逻辑
	
	var direction = Vector2.ZERO
	
	if is_chasing and player:
		# 追击玩家
		direction = (player.global_position - global_position).normalized()
		velocity = direction * (speed * chase_speed_multiplier)
	else:
		# 正常游荡
		velocity = wander.direction * speed
		direction = wander.direction
	
	# 检测方向是否改变
	if direction != Vector2.ZERO and direction != velocity.normalized():
		emit_signal("direction_changed", direction)
	
	# 根据移动方向更新动画
	if abs(direction.y) > abs(direction.x):
		if direction.y > 0:
			animation_player.play("walk_down")
		else:
			animation_player.play("walk_up")
	else:
		if direction.x > 0:
			animation_player.play("walk_right")
		else:
			animation_player.play("walk_left")
	
	# 移动角色
	move_and_slide()
	
	# 检查是否与玩家发生碰撞
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider and collider.name == "Player":
			# 根据玩家的相对方向播放攻击动画
			play_attack_animation(collider.global_position)
			# 玩家扣血
			damage_player()
			# 骷髅被击晕
			stun_skeleton()

func damage_player():
	hurt_box.monitoring = true  # 确保攻击开始时开启监控

func stun_skeleton():
	if not is_stunned:  # 防止重复击晕
		is_stunned = true
		stun_timer = 0.5 # 0.5秒击晕时间
		velocity = Vector2.ZERO  # 停止移动
		animation_player.stop()  # 停止动画
		print("骷髅被击晕 0.5 秒")

# 根据玩家位置播放对应方向的攻击动画
func play_attack_animation(player_pos: Vector2) -> void:
	var direction = player_pos - global_position
	
	# 根据相对方向确定攻击动画
	if abs(direction.y) > abs(direction.x):
		if direction.y > 0:
			animation_player.play("att_down")
		else:
			animation_player.play("att_up")
	else:
		if direction.x > 0:
			animation_player.play("att_right")
		else:
			animation_player.play("att_left")
			
	# 等待动画结束再继续移动
	await animation_player.animation_finished

func _on_area_2d_body_entered(body):
	if body.name == "Player":
		player = body
		is_chasing = true

func _on_area_2d_body_exited(body):
	if body.name == "Player":
		player = null
		is_chasing = false
		hurt_box.monitoring = false  # 确保攻击开始时开启监控
