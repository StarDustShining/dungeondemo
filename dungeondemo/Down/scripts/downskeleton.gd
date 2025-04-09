extends CharacterBody2D

@export var speed = 100  # 移动速度
@export var chase_speed_multiplier = 1.5  # 追击时的速度倍数
@export var damage = 0.5  # 对玩家造成的伤害

@onready var animation_player = $AnimationPlayer
@onready var wander = $Wander
@onready var area_2d = $Area2D
@onready var audio_player = $AudioStreamPlayer2D if has_node("AudioStreamPlayer2D") else null

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
	
	# 创建音频播放器（如果不存在）
	if not audio_player:
		audio_player = AudioStreamPlayer2D.new()
		add_child(audio_player)
		audio_player.max_distance = 2000
		audio_player.volume_db = -10
	
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
		
		if collider and collider.name == "Downplayer":
			# 根据玩家的相对方向播放攻击动画
			play_attack_animation(collider.global_position)
			# 玩家扣血
			damage_player(collider)
			# 播放攻击声音
			play_attack_sound()
			# 骷髅被击晕
			stun_skeleton()

func damage_player(player_node):
	# 直接对碰撞的玩家对象使用UpdateHp
	if player_node.has_method("UpdateHp"):
		# 确保至少扣1点血
		var damage_amount = max(1, int(damage))
		player_node.UpdateHp(-damage_amount)
		print("直接对玩家造成伤害: ", damage_amount)
	else:
		print("无法对玩家造成伤害，玩家脚本没有UpdateHp方法")

func stun_skeleton():
	if not is_stunned:  # 防止重复击晕
		is_stunned = true
		stun_timer = 0.5 # 0.5秒击晕时间
		velocity = Vector2.ZERO  # 停止移动
		animation_player.stop()  # 停止动画
		# 播放击晕声音
		play_stun_sound()
		print("骷髅被击晕 0.5 秒")

# 播放攻击声音
func play_attack_sound():
	if not audio_player or attack_sound == null:
		return
		
	audio_player.stream = attack_sound
	audio_player.pitch_scale = randf_range(0.9, 1.1)  # 随机音调变化
	audio_player.play()

# 播放击晕声音
func play_stun_sound():
	if audio_player and stun_sound:
		audio_player.stream = stun_sound
		audio_player.pitch_scale = randf_range(0.9, 1.1)
		audio_player.play()

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
	if body.name == "Downplayer":
		player = body
		is_chasing = true

func _on_area_2d_body_exited(body):
	if body.name == "Downplayer":
		player = null
		is_chasing = false
