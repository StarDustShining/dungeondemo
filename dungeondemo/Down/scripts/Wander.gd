extends Node2D

# 巡逻系统脚本：控制角色在指定区域内进行随机巡逻移动
# 通过在圆形区域内生成多个巡逻点，并在这些点之间随机移动来实现巡逻行为

@export var group_name: String = "First"  # 巡逻点组的名称，用于标识不同的巡逻区域
@export var patrol_radius : float = 200.0  # 巡逻区域的半径范围
@export var patrol_points : int = 4  # 要生成的巡逻点数量
@export var speed : float = 100.0  # 角色移动速度
@export var min_distance : float = 10.0  # 到达巡逻点的最小距离阈值

var positions : Array  # 存储所有生成的巡逻点
var temp_positions : Array  # 临时数组，用于随机打乱巡逻点顺序
var current_position : Marker2D  # 当前目标巡逻点
var direction : Vector2 = Vector2.ZERO  # 当前移动方向

func _ready():
	# 初始化时在圆形区域内生成随机分布的巡逻点
	positions = []
	for i in range(patrol_points):
		# 计算每个巡逻点的角度，均匀分布在圆周上
		var angle = (2 * PI * i) / patrol_points
		# 在基础位置的基础上添加随机偏移，使巡逻更自然
		var offset = Vector2(
			cos(angle) * patrol_radius + randf_range(-20, 20),
			sin(angle) * patrol_radius + randf_range(-20, 20)
		)
		# 创建新的巡逻点标记
		var marker = Marker2D.new()
		marker.position = global_position + offset
		get_parent().call_deferred("add_child", marker)
		positions.append(marker)
	
	# 初始化巡逻系统
	_get_positions()
	_get_next_position()

func _physics_process(_delta):
	# 如果没有当前目标点，获取新的目标点
	if !current_position:
		_get_next_position()
		return
	
	# 如果已经接近当前目标点，则选择下一个目标点    
	if global_position.distance_to(current_position.position) < min_distance:
		_get_next_position()
	else:
		# 计算朝向目标点的方向并移动
		direction = global_position.direction_to(current_position.position)
		global_position += direction * speed * _delta

func _get_positions():
	# 复制并打乱巡逻点数组，确保随机访问顺序
	temp_positions = positions.duplicate()
	temp_positions.shuffle()

func _get_next_position():
	# 如果临时数组为空，重新获取并打乱巡逻点
	if temp_positions.is_empty():
		_get_positions()
	
	# 安全检查：确保有可用的巡逻点    
	if temp_positions.is_empty():
		push_error("No positions found in group: " + group_name)
		return
	
	# 获取下一个巡逻点并更新移动方向    
	current_position = temp_positions.pop_front()
	if current_position:
		direction = global_position.direction_to(current_position.position).normalized()
	else:
		direction = Vector2.ZERO
