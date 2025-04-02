class_name InventoryData extends Resource

@export var slots : Array[ SlotData ]

signal inventory_updated #更新信号



func add_item(item: ItemData, count: int = 1) -> bool:
	for s in slots:
		if s:
			if s.item_data == item:
				s.quantity += count
				inventory_updated.emit() #背包更新即发送信号
				return true
	
	for i in slots.size():
		if slots[i] == null:
			var new = SlotData.new()
			new.item_data = item
			new.quantity = count
			slots[i] = new
			inventory_updated.emit() #背包更新即发送信号
			return true
	
	print("inventory was full!")
	
	return false
