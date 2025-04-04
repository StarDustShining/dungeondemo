@tool
class_name Table extends Node

var is_open: bool = false

# 直接使用场景路径
var game_path: String = "res://Level/Game01/game01.tscn"

@onready var interact_area: Area2D = $Area2D
var minigame_instance: Node = null  # 用于存储加载的小游戏实例


func _ready() -> void:
	interact_area.area_entered.connect(OnAreaEnter)
	interact_area.area_exited.connect(OnAreaExit)

func player_interact() -> void:
	# 使用 await 调用协程，并获取返回值
	minigame_instance = await LevelManager.load_minigame(game_path)
	# 检查 minigame_instance 是否为 null
	if minigame_instance == null:
		print("错误: 无法加载小游戏实例，请检查场景路径和资源。")
		return
	# 检查 minigame_finished 信号是否存在
	if minigame_instance.has_signal("minigame_finished"):
		minigame_instance.minigame_finished.connect(_on_minigame_completed)
		print("信号触发")
	else:
		print("错误: 小游戏实例没有 'minigame_finished' 信号。")

func OnAreaEnter(_a: Area2D) -> void:
	PlayerManager.interact_pressed.connect(player_interact)

func OnAreaExit(_a: Area2D) -> void:
	PlayerManager.interact_pressed.disconnect(player_interact)

func _on_minigame_completed() -> void:
	# 实例化 item_pickup
	var item_pickup = preload("res://Items/item_pickup/item_pickup.gd").new()
	item_pickup.item_data = preload("res://Items/powder.tres")  # 假设 powder 是一个 ItemData 资源
	item_pickup.position = self.position  # 设置 item_pickup 的位置为 Table 节点的位置
	get_parent().add_child(item_pickup)  # 将 item_pickup 添加到主场景中
