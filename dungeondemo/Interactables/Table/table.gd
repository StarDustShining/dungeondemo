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
	# 检查玩家背包中是否有 powder
	var has_powder = false
	for slot in PlayerManager.INVENTORY_DATA.slots:
		if slot and slot.item_data and slot.item_data.resource_path == "res://Items/powder.tres":
			has_powder = true
			break
	if has_powder:
		print("无法与 table 互动，背包中已有 powder。")
		return
	# 使用 await 调用协程，并获取返回值
	minigame_instance = await LevelManager.load_minigame(game_path)


func OnAreaEnter(_a: Area2D) -> void:
	PlayerManager.interact_pressed.connect(player_interact)

func OnAreaExit(_a: Area2D) -> void:
	PlayerManager.interact_pressed.disconnect(player_interact)

func _on_game01_completed() -> void:
	# 加载场景文件并实例化 item_pickup
	var item_pickup_scene = preload("res://Items/item_pickup/ItemPickup.tscn")
	var item_pickup = item_pickup_scene.instantiate()
	if item_pickup == null:
		print("错误: 无法实例化 item_pickup。")
		return
	# 设置 item_pickup 的属性
	item_pickup.item_data = preload("res://Items/powder.tres")  # 假设 powder 是一个 ItemData 资源
	if item_pickup.item_data == null:
		print("错误: 无法加载 powder.tres 资源。")
		return
	item_pickup.position = self.position  # 设置 item_pickup 的位置为 Table 节点的位置
	get_parent().add_child(item_pickup)  # 将 item_pickup 添加到主场景中
	print("item_pickup 已成功添加到场景中。")
