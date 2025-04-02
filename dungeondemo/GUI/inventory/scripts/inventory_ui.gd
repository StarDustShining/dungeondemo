class_name InventoryUI extends Control

const INVENTORY_SLOT = preload("res://GUI/inventory/inventory_slot.tscn")

@export var data: InventoryData

func _ready() -> void:
	#小bug：不打开暂停页面或手动点击物品无注意力格子
	clear_inventory() #先清空显示队列
	update_inventory() #更新玩家背包
	
	PauseMenu.shown.connect( clear_inventory )
	PauseMenu.hidden.connect( update_inventory )
	pass


func clear_inventory() -> void:
	for c in get_children():
		c.queue_free()


func update_inventory() -> void:
	for s in data.slots:
		var new_slot = INVENTORY_SLOT.instantiate()
		add_child(new_slot)
		new_slot.slot_data = s
	
	get_child(0).grab_focus()
