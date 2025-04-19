class_name InventoryUI extends Control

const INVENTORY_SLOT = preload("res://GUI/inventory/inventory_slot.tscn")

var focus_index : int = 0

@export var data: InventoryData

func _ready() -> void:
	clear_inventory() #先清空显示队列
	await get_tree().process_frame #背包高亮显示
	update_inventory() #更新玩家背包
	
	PauseMenu.shown.connect( clear_inventory )
	PauseMenu.hidden.connect( update_inventory )
	
	data.changed.connect( on_inventory_changed )
	
	if data:
		data.inventory_updated.connect(update_inventory) #监听inventory_data
	pass


func clear_inventory() -> void:
	for c in get_children():
		c.queue_free()
	#await get_tree().process_frame #等待一帧，确保上一个UI销毁


func update_inventory(i : int = 0) -> void:
	await clear_inventory() #等待一帧，确保UI已经清理再更新
	
	for s in data.slots:
		var new_slot = INVENTORY_SLOT.instantiate()
		add_child(new_slot)
		new_slot.slot_data = s
		new_slot.focus_entered.connect( item_focused )
	
	await get_tree().process_frame
	get_child( i ).grab_focus()

func item_focused() -> void:
	for i in get_child_count():
		if get_child(i).has_focus():
			focus_index = i
			return
	pass


func on_inventory_changed() -> void:
	var i = focus_index
	clear_inventory()
	update_inventory( i )
