class_name InventoryData extends Resource

@export var slots: Array[SlotData] = []  # 确保 slots 被正确初始化

signal inventory_updated  # 更新信号

func _init():
	# 初始化 slots，确保其不为 null
	if slots == null:
		slots = []

func add_item(item: ItemData, count: int = 1) -> bool:
	if slots == null:
		print("错误: slots 未初始化。")
		return false
	for s in slots:
		if s:
			if s.item_data == item:
				s.quantity += count
				inventory_updated.emit()  # 背包更新即发送信号
				return true
	for i in range(slots.size()):
		if slots[i] == null:
			var new = SlotData.new()
			new.item_data = item
			new.quantity = count
			slots[i] = new
			inventory_updated.emit()  # 背包更新即发送信号
			return true
	print("inventory was full!")
	return false

# 添加 remove_item 方法
func remove_item(index: int) -> void:
	if index >= 0 and index < slots.size():
		slots[index] = null
		inventory_updated.emit()  # 背包更新即发送信号
