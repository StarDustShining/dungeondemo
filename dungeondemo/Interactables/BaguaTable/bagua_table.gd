@tool
class_name BaguaTable extends Node

@onready var interact_area: Area2D = $E

# 定义八卦石的资源路径
var bagua_stones = [
	"res://Items/xun.tres",
	"res://Items/qian.tres",
	"res://Items/dui.tres",
	"res://Items/li.tres",
	"res://Items/zhen.tres",
	"res://Items/kun.tres",
	"res://Items/gen.tres",
	"res://Items/kan.tres"
]

func _ready() -> void:
	interact_area.area_entered.connect(OnAreaEnter)
	interact_area.area_exited.connect(OnAreaExit)

func player_interact() -> void:
	# 检查玩家背包中是否有足够数量的八卦石
	var has_all_bagua_stones = true
	for bagua_stone in bagua_stones:
		var has_bagua_stone = false
		for slot in PlayerManager.INVENTORY_DATA.slots:
			if slot and slot.item_data and slot.item_data.resource_path == bagua_stone:
				has_bagua_stone = true
				break
		if not has_bagua_stone:
			has_all_bagua_stones = false
			break

	if has_all_bagua_stones:
		# 玩家背包中有足够的八卦石，执行交互逻辑
		print("玩家背包中有足够的八卦石，执行交互逻辑")
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
	else:
		# 玩家背包中没有足够的八卦石，提示玩家
		print("玩家背包中没有足够的八卦石")

func OnAreaEnter(_a: Area2D) -> void:
	PlayerManager.interact_pressed.connect(player_interact)

func OnAreaExit(_a: Area2D) -> void:
	PlayerManager.interact_pressed.disconnect(player_interact)
