extends CharacterBody2D

@export var speed = 100  # 移动速度
@export var chase_speed_multiplier = 1.5  # 追击时的速度倍数

@onready var animation_player = $AnimationPlayer
@onready var wander = $Wander
@onready var area_2d = $Area2D

var is_chasing = false
var player = null

func _ready():
	# 设置Wander节点的参数
	wander.speed = speed
	
	# 连接Area2D的信号
	area_2d.body_entered.connect(_on_area_2d_body_entered)
	area_2d.body_exited.connect(_on_area_2d_body_exited)
	
	# 开始时播放向下走动画
	animation_player.play("walk_down")

func _physics_process(delta):
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

func _on_area_2d_body_entered(body):
	if body.name == "Downplayer":
		player = body
		is_chasing = true

func _on_area_2d_body_exited(body):
	if body.name == "Downplayer":
		player = null
		is_chasing = false
