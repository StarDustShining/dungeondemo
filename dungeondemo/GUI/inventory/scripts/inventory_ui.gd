class_name InventoryUI extends Control

const INVENTORY_SLOT = preload("res://GUI/inventory/inventory_slot.tscn")

@export var data: InventoryData

func _ready() -> void:
	clear_inventory() #先清空显示队列
	await get_tree().process_frame #背包高亮显示
	update_inventory() #更新玩家背包
	
	PauseMenu.shown.connect( clear_inventory )
	PauseMenu.hidden.connect( update_inventory )
	
	if data:
		data.inventory_updated.connect(update_inventory) #监听inventory_data
	pass


func clear_inventory() -> void:
	for c in get_children():
		c.queue_free()
	await get_tree().process_frame #等待一帧，确保上一个UI销毁


func update_inventory() -> void:
	await clear_inventory() #等待一帧，确保UI已经清理再更新
	
	for s in data.slots:
		var new_slot = INVENTORY_SLOT.instantiate()
		add_child(new_slot)
		new_slot.slot_data = s
	
	get_child(0).grab_focus()
