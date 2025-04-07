extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var area_2d: Area2D = $Area2D
@onready var mirror_collision_shape: CollisionShape2D = $Mirror/mirror

# 定义动画名称列表
var animations = ["up", "right_up", "right", "right_down", "down", "left_down", "left", "left_up"]
var reverse_animations = []  # 定义反转后的动画数组

# 导出变量，允许在编辑器中选择初始动画
@export var initial_direction: String = "up"

# 玩家是否进入区域的标志
var player_in_area: bool = false

# 当前状态
var current_state: String

# 控制动画切换的计时器（避免过于灵敏）
var animation_cooldown: float = 0.3  # 设定切换动画的冷却时间（秒）
var time_since_last_switch: float = 0  # 上次切换的时间

func _ready():
	set_physics_process(true)
	# 反转动画数组
	reverse_animations = animations.duplicate()  # 创建一个副本
	reverse_animations.reverse()  # 反转副本
	area_2d.area_entered.connect(_on_Area2D_area_entered)
	# 连接Area2D的area_exited信号
	area_2d.area_exited.connect(_on_Area2D_area_exited)
	
	# 初始化状态
	current_state = initial_direction
	animation_player.play(current_state)

func _physics_process(delta):
	# 确保不自动滑动
	if velocity.length() > 0:
		move_and_slide()
	else:
		velocity = Vector2.ZERO
	
	# 检测玩家是否在互动范围内
	if player_in_area:
		# 增加冷却时间的检测
		time_since_last_switch += delta
		if Input.is_action_just_pressed("Q") and time_since_last_switch >= animation_cooldown:  # 假设Q键绑定为ui_select
			switch_state(reverse_animations)
			time_since_last_switch = 0  # 重置冷却时间
		elif Input.is_action_just_pressed("R") and time_since_last_switch >= animation_cooldown:  # 假设R键绑定为ui_accept
			switch_state(animations)
			time_since_last_switch = 0  # 重置冷却时间

func switch_state(animation_list: Array):
	# 找到当前状态在列表中的索引
	var current_index = animation_list.find(current_state)
	if current_index != -1:
		# 计算下一个状态的索引
		var next_index = (current_index + 1) % animation_list.size()
		current_state = animation_list[next_index]
		animation_player.play(current_state)

# 当玩家进入区域时触发
func _on_Area2D_area_entered(area: Area2D) -> void:
	player_in_area = true
	print("Player entered the area")

# 当玩家离开区域时触发
func _on_Area2D_area_exited(area: Area2D) -> void:
	player_in_area = false
	print("Player left the area")
