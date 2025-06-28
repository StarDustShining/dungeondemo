class_name Game01 extends Node2D

signal minigame_finished  # 定义信号
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var player:Player=PlayerManager.player

# 定义变量来存储每个瓶子实例化物品的数量
var charcoal_count = 0  # 炭的数量
var saltpetre_count = 0  # 硝石的数量
var sulphur_count = 0  # 硫磺的数量
var ammo_weight = 0.0  # 炸药重量

func _ready():
	self.visible = true  # 隐藏小游戏
	animated_sprite_2d.visible=false
	player.get_node("Camera2D").enabled = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("退出"):
		end_minigame()

func end_minigame():
	self.visible = false  # 隐藏小游戏
	await get_tree().process_frame
	minigame_finished.emit()
	var table = get_node("/root/TrebuchetLevel/Table")
	table._on_game01_completed()
	player.get_node("Camera2D").enabled = true
	
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

# 新增函数来获取计数器值
func get_counts() -> Dictionary:
	return {
		"charcoal_count": charcoal_count,
		"saltpetre_count": saltpetre_count,
		"sulphur_count": sulphur_count
	}
