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
	
	PlayerManager.inventory_ui_ref = self ###
	pass


func clear_inventory() -> void:
	for c in get_children():
		c.queue_free()
	await get_tree().process_frame #等待一帧，确保上一个UI销毁

var is_updating := false ###
func update_inventory(i : int = -1) -> void:
	#await clear_inventory() #等待一帧，确保UI已经清理再更新
	if is_updating: ###
		return
	is_updating = true
	
	await clear_inventory() ###
	await get_tree().process_frame ###
	
	for s in data.slots:
		var new_slot = INVENTORY_SLOT.instantiate()
		add_child(new_slot)
		new_slot.slot_data = s
		new_slot.focus_entered.connect( item_focused )
	
	await get_tree().process_frame
	#get_child( i ).grab_focus()
	
	###
	var focus_i = i
	if focus_i == -1:
		focus_i = data.last_added_index
	if focus_i >= 0 and focus_i < get_child_count():
		var target = get_child(focus_i)
		if target != null:
			target.grab_focus()
	else:
		if get_child_count() > 0:
			get_child(0).grab_focus()
	
	is_updating = false###

func item_focused() -> void:
	for i in get_child_count():
		if get_child(i).has_focus():
			focus_index = i
			return
	pass


func on_inventory_changed() -> void:
	#clear_inventory()
	update_inventory()
	
###
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			change_focus(-1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			change_focus(1)

func change_focus(delta: int) -> void:
	var count = get_child_count()
	if count == 0:
		return
	focus_index = (focus_index + delta + count) % count
	get_child(focus_index).grab_focus()
