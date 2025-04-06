extends Node2D

var bounces := 3  # 激光反弹次数限制
const MAX_LENGTH := 2000  # 激光的最大长度（射程）

@onready var line = $Line2D  # 引用 Line2D 节点，用于绘制激光路径
var max_cast_to  # 最大射程向量，固定为 Y 轴正方向

var lasers := []  # 存储所有 RayCast2D 节点（包括初始激光和反弹激光）

func _ready():
	"""
	初始化函数：
	- 设置激光节点的位置与夜明珠的位置一致。
	- 创建多个 RayCast2D 节点，用于模拟激光的多次反弹。
	- 初始化激光的最大射程向量。
	- 配置 Line2D 和初始 RayCast2D 节点。
	"""
	# 确保激光节点的位置与夜明珠的位置一致
	self.global_position = get_node("..").global_position
	
	lasers.append($Laser)  # 将初始 RayCast2D 节点添加到 lasers 列表中
	for i in range(bounces):  # 根据反弹次数创建额外的 RayCast2D 节点
		var raycast = $Laser.duplicate()  # 复制初始 RayCast2D 节点
		raycast.enabled = false  # 禁用新创建的 RayCast2D 节点（待碰撞时启用）
		add_child(raycast)  # 将新创建的 RayCast2D 节点添加为子节点
		lasers.append(raycast)  # 将新创建的 RayCast2D 节点添加到 lasers 列表中
	
	update_laser_direction()  # 初始化激光方向

func update_laser_direction():
	"""
	更新激光的方向，使其固定为 Y 轴正方向。
	"""
	max_cast_to = Vector2(0, MAX_LENGTH)  # 固定最大射程向量为 Y 轴正方向
	
	for raycast in lasers:  # 更新所有 RayCast2D 节点的目标位置
		raycast.target_position = max_cast_to

func _process(_delta):
	"""
	每帧更新函数：
	- 更新激光路径。
	- 检测每个 RayCast2D 的碰撞情况，并根据结果更新路径和反弹逻辑。
	"""
	$End.emitting = true  # 启用 GPUParticles2D 效果（激光终点效果）
	
	line.clear_points()  # 清空 Line2D 的路径点
	line.add_point(Vector2.ZERO)  # 添加起点（相对于当前节点的位置，即夜明珠的位置）
	
	max_cast_to = Vector2(0, MAX_LENGTH)  # 固定最大射程向量为 Y 轴正方向
	
	var idx = -1  # 当前处理的 RayCast2D 索引
	for raycast in lasers:  # 遍历所有 RayCast2D 节点
		idx += 1  # 增加索引
		var raycastcollision = raycast.get_collision_point()  # 获取当前 RayCast2D 的碰撞点
		
		raycast.target_position = max_cast_to  # 设置当前 RayCast2D 的目标位置
		if raycast.is_colliding():  # 如果当前 RayCast2D 发生碰撞
			line.add_point(raycastcollision - global_position)  # 在 Line2D 中添加碰撞点（相对于当前节点的位置）
			
			max_cast_to = max_cast_to.bounce(raycast.get_collision_normal())  # 计算反弹后的射程向量
			if idx < lasers.size() - 1:  # 如果还有未使用的 RayCast2D 节点
				lasers[idx + 1].enabled = true  # 启用下一个 RayCast2D 节点
				lasers[idx + 1].global_position = raycastcollision + (1 * max_cast_to.normalized())  # 设置下一个 RayCast2D 的位置
			if idx == lasers.size() - 1:  # 如果是最后一个 RayCast2D 节点
				$End.global_position = raycastcollision  # 设置 GPUParticles2D 的位置为最终碰撞点
		else:  # 如果当前 RayCast2D 没有发生碰撞
			line.add_point(max_cast_to)  # 在 Line2D 中添加终点（相对于当前节点的位置）
			$End.emitting = false  # 禁用 GPUParticles2D 效果
			break  # 结束循环
