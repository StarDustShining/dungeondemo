extends Node2D
@onready var video_stream_player: VideoStreamPlayer = $VideoStreamPlayer

# 定义地刺节点的引用
@onready var spikes = [
	$Spike/Spike1,
	$Spike/Spike2,
	$Spike/Spike3,
	$Spike/Spike4,
	$Spike/Spike5,
	$Spike/Spike6,
	$Spike/Spike7,
	$Spike/Spike8
]

# 定义 Marker 节点的引用
@onready var markers = [
	$Markers/xun, 
	$Markers/qian, 
	$Markers/dui, 
	$Markers/li, 
	$Markers/zhen,
	$Markers/kun, 
	$Markers/gen, 
	$Markers/kan
]

# 定义 AnimationPlayer 节点的引用
@onready var animation_player: AnimationPlayer = $Seisomgraph/AnimationPlayer
@onready var metal: AudioStreamPlayer2D = $Metal
@onready var long_yin: AudioStreamPlayer2D = $LongYin

# 定义尖刺陷阱和地动仪动画的映射
var spike_to_seisomgraph_animation = {
	"Spike1": "1",
	"Spike2": "2",
	"Spike3": "3",
	"Spike4": "4",
	"Spike5": "5",
	"Spike6": "6",
	"Spike7": "7",
	"Spike8": "8"
}

# 定义 Bead 预制体
@onready var bead_scene: PackedScene = preload("res://Interactables/Seisomgraph/Bead.tscn")

# 定义 Bagua 预制体
@onready var bagua_scene: PackedScene = preload("res://Items/item_pickup/Bagua.tscn")

@onready var timer: Timer = $Timer

# 存储当前选中的地刺索引
var selected_spikes = []
var pre_selected_spikes = []  # 记录上一轮掉落的地刺
# 存储当前实例化的 Bead 节点
var bead_instances = {}
# 存储当前实例化的 Bagua 节点
var bagua_instances = {}

# 获取 Seisomgraph 节点
@onready var seisomgraph = $Seisomgraph

func _ready() -> void:
	self.y_sort_enabled = true
	PlayerManager.set_as_parent(self)
	LevelManager.level_load_started.connect(_free_level)
	LevelManager.minigame_load_started.connect(_pause_level)
	# 隐藏所有地刺并禁用其 hurt_box 的监测
	for spike in spikes:
		spike.visible = false
		var hurt_box = spike.get_node("hurt_box")
		if hurt_box:
			hurt_box.monitoring = false
	# 将定时器添加到场景中
	add_child(timer)
	# 设置定时器的间隔时间
	timer.wait_time = 10.0
	# 连接定时器的timeout信号到随机显示地刺的函数
	timer.timeout.connect(_on_Timer_timeout)
	# 启动定时器
	timer.start()
	pre_selected_spikes = [0,1,2,3,4,5,6,7]
	_reset_beads()
	
func _process(delta: float) -> void:
	await get_tree().process_frame
		# 检查玩家背包中是否有 longlin.tres
	check_for_longlin()

var _has_played_long_yin : bool = false ###
func check_for_longlin() -> void:
	# 定义 longlin.tres 的资源路径
	var longlin_resource_path = "res://Items/longlin.tres"
	
	if _has_played_long_yin: ###
		return
	
	# 遍历玩家背包中的物品
	for slot in PlayerManager.INVENTORY_DATA.slots:
		if slot and slot.item_data and slot.item_data.resource_path == longlin_resource_path:
			# 播放 long_yin 音频
			long_yin.play()
			print("检测到 longlin.tres，播放 long_yin 音频")
			video_stream_player.play()
			_has_played_long_yin = true ###
			break

func _on_Timer_timeout():
	# 重新启动定时器
	timer.start()
	
	# 随机选择地刺的数量（最多3个）
	var spike_count = randi() % 4  # 0到3之间的随机数
	if spike_count == 0:
		spike_count = 1  # 确保至少有一个地刺出现

	# 创建一个集合来存储已经选择的地刺索引
	selected_spikes = []

	# 随机选择地刺
	while selected_spikes.size() < spike_count:
		var index = randi() % spikes.size()
		if not selected_spikes.has(index):
			selected_spikes.append(index)

	# 将当前选中的地刺保存到 pre_selected_spikes 中，供下一轮使用
	pre_selected_spikes = selected_spikes.duplicate()
	
	# 让 Bead 同时开始掉落
	_activate_beads()
	metal.play()
	
	# 播放选中的地刺对应的动画
	for index in selected_spikes:
		var spike_name = spikes[index].name
		var animation_name = spike_to_seisomgraph_animation.get(spike_name, "idle")
		var long_node = seisomgraph.get_node("longs/" + "long" + animation_name)
		var animation_player = long_node.get_node(animation_name)
		animation_player.play(animation_name)
	
	# 设置延迟时间
	await get_tree().create_timer(2.0).timeout  # 可根据需求调整时间
	
	# 显示选中的地刺并启用其 hurt_box 的监测
	for index in selected_spikes:
		spikes[index].visible = true
		var hurt_box = spikes[index].get_node("hurt_box")
		if hurt_box:
			hurt_box.monitoring = true
	
	# 随机选择 Marker 节点来实例化 Bagua 物品
	var bagua_count = randi() % 4  # 0到3之间的随机数
	if bagua_count == 0:
		bagua_count = 1  # 确保至少有一个 Bagua 出现

	# 创建一个集合来存储已经选择的 Marker 索引
	var selected_markers = []

	# 随机选择 Marker
	while selected_markers.size() < bagua_count:
		var index = randi() % markers.size()
		if not selected_markers.has(index):
			selected_markers.append(index)

	# 在选中的 Marker 节点位置实例化 Bagua 物品
	for index in selected_markers:
		var marker = markers[index]
		var bagua_instance = bagua_scene.instantiate()
		# 使用 load 函数加载资源
		bagua_instance.item_data = load("res://Items/" + marker.name + ".tres")
		bagua_instance.position = marker.global_position
		get_parent().add_child(bagua_instance)
		bagua_instances[marker.name] = bagua_instance
		# 设置销毁计时器
		var destroy_timer = Timer.new()
		destroy_timer.wait_time = 10.0  # 根据需求调整时间
		destroy_timer.one_shot = true
		# 使用 Callable 来传递 bagua_instance
		destroy_timer.timeout.connect(Callable(self, "_on_Bagua_destroy_timeout").bind(bagua_instance))
		add_child(destroy_timer)  # 确保计时器添加到当前节点
		destroy_timer.start()

	await get_tree().create_timer(1.0).timeout
	# 根据上一轮的掉落地刺重置 Bead
	_reset_beads()
	
	await get_tree().create_timer(5.0).timeout
	
	for spike in spikes:
		spike.visible = false
		var hurt_box = spike.get_node("hurt_box")
		if hurt_box:
			hurt_box.monitoring = false

# 不销毁场景，而是仅清除与小游戏相关的部分
func _free_level() -> void:
	PlayerManager.unparent_player(self)
	queue_free()

func _pause_level() -> void:
	pass

# 激活掉落的 Bead
func _activate_beads():
	for index in selected_spikes:
		var spike_name = spikes[index].name
		if bead_instances.has(spike_name):
			var bead_instance = bead_instances[spike_name]
			bead_instance.sleeping = false  # 让 Bead 变为活动状态

# 重置 Bead 的位置，基于上一轮掉落的 Bead
func _reset_beads():
	# 先清除上一轮掉落的 Bead
	for index in pre_selected_spikes:
		var spike_name = spikes[index].name
		if bead_instances.has(spike_name):
			var bead_instance = bead_instances[spike_name]
			bead_instance.queue_free()  # 销毁 Bead 实例
	for index in pre_selected_spikes:
		var spike_name = spikes[index].name
		var bead_instance = bead_scene.instantiate()
		bead_instance.position = get_initial_bead_position(spike_name)
		bead_instance.sleeping = true  # 设置 Bead 为休眠状态
		seisomgraph.add_child(bead_instance)
		bead_instances[spike_name] = bead_instance

# 获取 Bead 的初始位置（相对于 Seisomgraph 的局部坐标）
func get_initial_bead_position(spike_name: String) -> Vector2:
	match spike_name:
		"Spike1":
			return Vector2(71, -35)
		"Spike2":
			return Vector2(22, -35)
		"Spike3":
			return Vector2(-23, -35)
		"Spike4":
			return Vector2(-68, -35)
		"Spike5":
			return Vector2(-88, -7)
		"Spike6":
			return Vector2(-40, 16)
		"Spike7":
			return Vector2(40, 16)
		"Spike8":
			return Vector2(88, -7)
		_:
			return Vector2(0, 0)  # 默认位置


# 销毁未被捡起的 Bagua 物品
func _on_Bagua_destroy_timeout(bagua_instance: Node2D) -> void:
	if bagua_instance.is_in_group("picked_up"):
		return  # 如果 Bagua 已经被捡起，则不销毁
	bagua_instance.queue_free()  # 销毁 Bagua 实例
