extends CharacterBody2D

@onready var rotation_area: Area2D = $RotationArea
@onready var reflect_area: CollisionShape2D = $ReflectArea/CollisionShape2D
@onready var block_area: CollisionShape2D = $BlockArea/CollisionShape2D
@onready var sprite_2d: Sprite2D = $Sprite2D

var state = ["up", "right_up", "right", "right_down", "down", "left_down", "left", "left_up"]
var reverse_state = []  # 用于反转动画数组
var current_state: String
var player_in_area: bool = false

@export var initial_state: String = "up"

func _ready():
	set_physics_process(true)
	# 反转动画数组
	reverse_state = state.duplicate()
	reverse_state.reverse()
	rotation_area.area_entered.connect(_on_Area2D_area_entered)
	rotation_area.area_exited.connect(_on_Area2D_area_exited)
	
	# 初始化状态
	current_state = initial_state

	# 设置sprite初始帧
	update_sprite()

func _physics_process(_delta):
		# 确保不自动滑动
	if velocity.length() > 0:
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		
	# 检测玩家是否在互动范围内
	if player_in_area:
		if Input.is_action_just_pressed("R"):
			switch_state(1)
		elif Input.is_action_just_pressed("Q"):
			switch_state(-1)

# 切换状态的函数，1表示正序，-1表示倒序切换
func switch_state(direction: int):
	var current_index = state.find(current_state)
	if current_index != -1:
		current_index = (current_index + direction) % state.size()
		current_state = state[current_index]
		update_sprite()
		update_areas()

# 更新sprite帧
func update_sprite():
	var index = state.find(current_state)
	if index != -1:
		sprite_2d.frame = index

# 更新reflect_area和block_area的属性（根据状态）
func update_areas():
	match current_state:
		"up":
			# 设置 reflect_area 和 block_area 的属性
			reflect_area.shape.size = Vector2(58.5, 1)  # 设定大小
			reflect_area.position = Vector2(0, -1)
			reflect_area.rotation_degrees = 0  # 设定旋转（使用 rotation_degrees）

			block_area.shape.size = Vector2(58.5, 1)
			block_area.position = Vector2(0, 3)
			block_area.rotation_degrees = 0  # 设定旋转（使用 rotation_degrees）

		"right_up":
			reflect_area.shape.size = Vector2(44.767, 3.0)
			reflect_area.position = Vector2(1, -1)
			reflect_area.rotation_degrees = 30  # 设定旋转（使用 rotation_degrees）

			block_area.shape.size = Vector2(44.767, 3.0)
			block_area.position = Vector2(0, 2)
			block_area.rotation_degrees = 30  # 设定旋转（使用 rotation_degrees）

		"right":
			reflect_area.shape.size = Vector2(60.25, 1)
			reflect_area.position = Vector2(3.5, 0)
			reflect_area.rotation_degrees = 90  # 设定旋转（使用 rotation_degrees）

			block_area.shape.size = Vector2(61.0, 3)
			block_area.position = Vector2(-2.0, 0.5)
			block_area.rotation_degrees = 90  # 设定旋转（使用 rotation_degrees）

		"right_down":
			reflect_area.shape.size = Vector2(50.631, 1.707)
			reflect_area.position = Vector2(0.703, 2.504)
			reflect_area.rotation_degrees = 135  # 设定旋转（使用 rotation_degrees）

			block_area.shape.size = Vector2(50.653, 2.525)
			block_area.position = Vector2(-0.984, 1.199)
			block_area.rotation_degrees = 135  # 设定旋转（使用 rotation_degrees）

		"down":
			reflect_area.shape.size = Vector2(50.631, 1.707)
			reflect_area.position = Vector2(-0.297, 1.504)
			reflect_area.rotation_degrees = 0  # 设定旋转（使用 rotation_degrees）

			block_area.shape.size = Vector2(50.653, 2.525)
			block_area.position = Vector2(0.016, -0.801)
			block_area.rotation_degrees = 0  # 设定旋转（使用 rotation_degrees）

		"left_down":
			reflect_area.shape.size = Vector2(45.641, 2.34)
			reflect_area.position = Vector2(-1.348, 0.603)
			reflect_area.rotation_degrees = -150.0  # 设定旋转（使用 rotation_degrees）

			block_area.shape.size = Vector2(44.409, 2.525)
			block_area.position = Vector2(-0.616, -1.166)
			block_area.rotation_degrees = -150.0  # 设定旋转（使用 rotation_degrees）

		"left":
			reflect_area.shape.size = Vector2(55.0, 1)
			reflect_area.position = Vector2(-3.5, -2.5)
			reflect_area.rotation_degrees = -90  # 设定旋转（使用 rotation_degrees）

			block_area.shape.size = Vector2(54.0, 3)
			block_area.position = Vector2(2.22, -3)
			block_area.rotation_degrees = -90  # 设定旋转（使用 rotation_degrees）

		"left_up":
			reflect_area.shape.size = Vector2(44.409, 2.124)
			reflect_area.position = Vector2(-1.301, -2.022)
			reflect_area.rotation_degrees = -30  # 设定旋转（使用 rotation_degrees）

			block_area.shape.size = Vector2(42.889, 2.864)
			block_area.position = Vector2(-0.496, 0)
			block_area.rotation_degrees = -30  # 设定旋转（使用 rotation_degrees）

# 当玩家进入区域时触发
func _on_Area2D_area_entered(_area: Area2D) -> void:
	player_in_area = true

# 当玩家离开区域时触发
func _on_Area2D_area_exited(_area: Area2D) -> void:
	player_in_area = false
