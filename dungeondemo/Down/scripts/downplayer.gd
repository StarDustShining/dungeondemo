extends CharacterBody2D

@export var walk_speed = 200 # 走路速度
@export var run_speed = 350 # 跑步速度

@onready var animation_player = $AnimationPlayer # 动画播放器节点引用
@onready var sprite = $Graphic/Sprite2D # 精灵节点引用

func _physics_process(_delta):
	# 获取输入向量
	var input_vector = Vector2.ZERO
	
	# 使用预设的方向键映射
	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1
		animation_player.play("walk_right")
	if Input.is_action_pressed("ui_left"):
		input_vector.x -= 1
		animation_player.play("walk_left")
	if Input.is_action_pressed("ui_down"):
		input_vector.y += 1
		animation_player.play("walk_down")
	if Input.is_action_pressed("ui_up"):
		input_vector.y -= 1
		animation_player.play("walk_up")
	
	# 归一化向量，确保斜向移动速度一致
	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		# 检测shift键是否按下，按下时使用run_speed，否则使用walk_speed
		var current_speed = run_speed if Input.is_action_pressed("ui_shift") else walk_speed
		velocity = input_vector * current_speed
	else:
		velocity = Vector2.ZERO
		# 如果没有移动，停止动画
		if animation_player.is_playing():
			animation_player.stop()
	
	# 应用移动
	move_and_slide()
