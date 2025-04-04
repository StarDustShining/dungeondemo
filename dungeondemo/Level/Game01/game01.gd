class_name Game01 extends Node2D

signal minigame_finished  # 定义信号

# 定义变量来存储每个瓶子实例化物品的数量
var charcoal_count = 0  # 炭的数量
var saltpetre_count = 0  # 硝石的数量
var sulphur_count = 0  # 硫磺的数量
var ammo_weight = 0.0  # 炸药重量

func _ready():
	#process_mode = Node.PROCESS_MODE_ALWAYS
	#set_process(true)
	#set_process_input(true)
	#set_process_unhandled_input(true)
	self.visible = true  # 隐藏小游戏

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("退出"):
		end_minigame()

#func end_minigame():
	#minigame_finished.emit()  # 触发小游戏完成信号
	#queue_free()  # 清除小游戏
	
func end_minigame():
	# 隐藏当前小游戏，而不是销毁
	self.visible = false  # 隐藏小游戏
	# 延迟信号触发，确保信号连接完成
	await get_tree().process_frame
	# 触发小游戏完成信号
	minigame_finished.emit()
	var table=get_node("/root/02/Table")
	table._on_game01_completed()
	
# 函数来更新每个瓶子实例化物品的数量
func increment_charcoal_count():
	charcoal_count += 1
	calculate_ammo_weight()

func increment_saltpetre_count():
	saltpetre_count += 1
	calculate_ammo_weight()

func increment_sulphur_count():
	sulphur_count += 1
	calculate_ammo_weight()

# 函数来计算炸药重量
func calculate_ammo_weight():
	ammo_weight = charcoal_count + saltpetre_count + sulphur_count

# 新增函数来获取炸药重量
func get_ammo_weight() -> float:
	return ammo_weight
