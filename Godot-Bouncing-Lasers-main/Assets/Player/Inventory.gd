extends Control

var RESET_SAVE = false
const SAVE_PATH = "user://inventory.save"

@onready var player = get_node("../../..")

const INV_SIZE = Vector2(5,6)
const ITEM_SIZE = Vector2(32,32)

var held_item : BaseItem
var old_held_item : BaseItem
# warning-ignore:narrowing_conversion
var inv = BaseItem._Array.new(INV_SIZE.x*INV_SIZE.y)
var counter = 1

var old_held_item_cycle = 5
var old_held_item_counter = 0

var delete_list = []
var delete_list_decay = 5
var delete_list_counter = delete_list_decay

var selection = 0

var old_armor = []

var unlocked_items := [Globals.ITEMS.WoodenSword]

signal selected_changed

func _ready():
	
	if RESET_SAVE:
		
#		_add_item(Globals.create_item(18,1,player),2)
#		_add_item(Globals.create_item(19,1,player),2)
#		_add_item(Globals.create_item(20,1,player),2)
#		_add_item(Globals.create_item(Globals.ITEMS.RefinedIntent,1,player),2)
#		_add_item(Globals.create_item(Globals.ITEMS.WoodenSword,1,player),2)
#		_add_item(Globals.create_item(Globals.ITEMS.UnrefinedFirePraecis,3,player),24)
#		_add_item(Globals.create_item(Globals.ITEMS.AloeVera,1,player),0)
		_add_item(Globals.create_item(Globals.ITEMS.BasicHarvester,1,player),1)
#		_add_item(Globals.create_item(Globals.ITEMS.RefinedIntent,1,player),1)
#		_add_item(Globals.create_item(Globals.ITEMS.Wood,10,player),1)
#		_add_item(Globals.create_item(Globals.ITEMS.IronOre,10,player),1)
#		_add_item(Globals.create_item(Globals.ITEMS.AnguisaniumOre,10,player),1)
		
		save()
	else:
		_load()
	
	inv.update()
	

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			__scroll_selection(1)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			__scroll_selection(-1)
	if event is InputEventKey and event.pressed:
		if event.keycode >= 49 and event.keycode <= 53:
			selection = event.keycode - 49
			__scroll_selection(0)
	

func _process(_delta):
	if held_item != null:
		held_item.node.position = $Holder.get_local_mouse_position() - ITEM_SIZE/2
	else:
		$Holder/SlotBlocker.hide()
	
	if old_held_item_counter >= 1:
		old_held_item_counter -= 1
	else:
		old_held_item = null
	
	if delete_list_counter >= 1:
		delete_list_counter -= 1
	else:
		delete_list.pop_front()
		delete_list_counter = delete_list_decay
	
	if Input.is_action_just_pressed("inventory_open"):
		toggle_bag()
	

func save():
	var f := File.new()
	f.open(SAVE_PATH, File.WRITE_READ)
	var inv_arr = []
	var save_dict = {
		"inventory": inv_arr,
		"unlocked_items": unlocked_items
	}
	for item in inv.items:
		if item == null:
			inv_arr.append(null)
		else:
			inv_arr.append({
				"index": item.index,
				"amount": item.amount
			})
	f.store_var(save_dict)
	f.close()

func _load():
	var f := File.new()
	
	if f.file_exists(SAVE_PATH):
		Globals.set_flag("first_run", false)
	
	f.open(SAVE_PATH, File.READ_WRITE)
	var save_dict = f.get_var()
	
	if Globals.get_flag("first_run"):
		_add_item(Globals.create_item(Globals.ITEMS.BasicHarvester,1,player),1)
	
	f.close()
	if save_dict:
		var i := 0
		for item in save_dict.inventory:
			if item != null:
				_add_item(Globals.create_item(item.index, item.amount, player), i)
			i += 1
		
		for item in save_dict.unlocked_items:
			if not unlocked_items.has(item):
				unlocked_items.append(item)

func remove_with_id(index : int, amount : int):
	inv.remove_with_id(index, amount)
	inv.update()

func _update():
	inv.update()

func has_item(item_idx: int) -> bool:
	return false

func _check_amount_with_id(id: int):
	return inv._check_amount_with_id(id)

func _add_item(item: BaseItem, slot := -1):
	#Right Click needs help
	
	if inv.empty_slots() == 0:
		return
	if slot == -1:
		slot = inv.append(item)
	else:
		slot = inv.add(item, slot)
		if slot == -1:
			#Item cant be added
			return
	
	$Holder.call_deferred("add_child", item.node)
	item.node.visible = $Bag.visible
	inv.update()
# warning-ignore:return_value_discarded
	item.node.connect("input_event", Callable(self, "_item_input").bind(item))
	_move_item_to_slot(item, slot)
	
	save()
	

func pickup_item(item : BaseItem):
	var temp = inv.fill_stacks(item.index, item.amount)
	if typeof(temp) != typeof(true):
		item.amount = temp
		_add_item(item)
	inv.update()
	save()

func _move_item_to_slot(item : BaseItem, slot : int):
	equip()
	emit_signal("selected_changed")
	if slot == -1:
		slot = inv.find(item)
	elif inv.get_slot(slot) != item:
		return
#
#	if (slot + 1) % int(INV_SIZE.x) == 0:
#		equip()
	
	var pos_vec = Vector2.ZERO
	pos_vec.x = slot % int(INV_SIZE.x)
	
	pos_vec.y = (slot - pos_vec.x) / int(INV_SIZE.x)
	item.node.position = pos_vec * ITEM_SIZE
	item.node.position += Vector2(0,14) if slot >= (INV_SIZE.y - 1) * INV_SIZE.x else Vector2.ZERO


# warning-ignore:unused_argument
func _item_input(_a, event, _b, item : BaseItem):
	if event is InputEventMouseButton:
		inv.update()
		#Left Click
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			#No item being held
			if held_item == null:
				__grab_item(item)
			#Item being held but item clicked on is not itself nor last held item
			elif held_item != item:
				#If items are the same index
				if held_item.index == item.index:#: and int(inv.find(item) + 1) % int(INV_SIZE.x) != 0 and not inv.find(item) == INV_SIZE.x * INV_SIZE.y - 1:
					var amount_left = (item.max_stack - item.amount)
					
					if amount_left == 0:
						return
					
					if amount_left >= held_item.amount:
						item.amount += held_item.amount
						delete_list.append(__free_held_item())
						#Adds to the list so queued up _item_input calls dont revive deleted item
						inv.destroy(delete_list[-1])
					else:
						item.amount = item.max_stack
						held_item.amount -= amount_left
					
				elif  item != old_held_item:
					
					var held_item_slot = inv.find(held_item)
					var item_slot = inv.find(item)
					var last_slot = INV_SIZE.x * INV_SIZE.y -1
					
					if ((item_slot + 1) % int(INV_SIZE.x) == 0 and item_slot != last_slot) \
					 or ((held_item_slot + 1) % int(INV_SIZE.x) == 0 and held_item_slot != last_slot):
						if (held_item.type != "armor" and held_item.type != "praecis") or held_item.type != item.type \
						 or held_item.armor_idx != item.armor_idx:
							return
					
					
					#If item is not the same type
					var old_item = held_item
					held_item = item
					
					old_item.hold(false)
					item.hold(true)
					
					
					inv.swap(held_item, old_item)
					_move_item_to_slot(old_item, -1)
					old_held_item = old_item
					old_held_item_counter = old_held_item_cycle
					_block_slot(inv.find(held_item), true)
			
			#Item being held was clicked on
			elif held_item == item:
				var slot = _get_slot_clicked_on()
				if slot == null:
					return
				if held_item.type != "armor" and held_item.type != "praecis" and int(slot + 1) % int(INV_SIZE.x) == 0 and not slot == INV_SIZE.x * INV_SIZE.y - 1:
					return
				if (held_item.type == "armor" or held_item.type == "praecis") and int(slot + 1) % int(INV_SIZE.x) == 0 and not slot == INV_SIZE.x * INV_SIZE.y - 1:
					if (slot + 1) / (INV_SIZE.y - 1) - 1 != held_item.armor_idx:
						return
				
				#Click was made on a free slot or on the held item slot
				if inv.get_slot(slot) == null or inv.get_slot(slot) == item:
					var temp = __free_held_item()
					if inv.get_slot(slot) != item:
						inv.change(slot,temp)
					_move_item_to_slot(temp, slot)
					_block_slot(slot, false)
		
		#Right Click			
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			#RightClicked some random item with no held item and there are free slots and the item has more than 2
			if held_item == null and inv.empty_slots() > 0 and item.amount >= 2:
				var new_item = Globals.create_item(item.index, int(ceil(item.amount / 2.0)),get_parent().get_parent().get_parent())
				item.amount = int(floor(item.amount / 2.0))
				
				_add_item(new_item)
				__grab_item(new_item)
				inv.update()

			#If item clicked on was held item
			elif held_item == item and held_item.amount >= 2:
				var slot = _get_slot_clicked_on()
				if slot == null:
					return
				#Cöocl was made on a free slot or on the held item slot
				if inv.get_slot(slot) == null or inv.get_slot(slot) == item:
					var new_item = Globals.create_item(item.index,1,get_parent().get_parent().get_parent())
					_add_item(new_item, slot)
					item.amount -= 1
					inv.update()




func _get_slot_clicked_on():
	var mouse_pos = $Holder.get_local_mouse_position()
	
	if (Globals.is_in_range_inclusive(mouse_pos.x, Vector2(0,INV_SIZE.x * ITEM_SIZE.x)) \
		and Globals.is_in_range_inclusive(mouse_pos.y, Vector2(0, (INV_SIZE.y-1) * ITEM_SIZE.y))):
		var inv_vect: Vector2 = (mouse_pos / ITEM_SIZE).floor()
		return inv_vect.x + inv_vect.y * (INV_SIZE.y-1)
	

	if (Globals.is_in_range_inclusive(mouse_pos.x, Vector2(0,INV_SIZE.x * ITEM_SIZE.x)) \
		and Globals.is_in_range_inclusive(mouse_pos.y, Vector2.ONE * ((INV_SIZE.y-1) * ITEM_SIZE.y + 14) + Vector2(0, ITEM_SIZE.y))):
		var x = int(mouse_pos.x / ITEM_SIZE.x)

		return x + (INV_SIZE.y-1) * INV_SIZE.x
	
	return null

#Sends the funny color rect to the original slot the held item came from
func _block_slot(slot : int, state : bool):
	if state:
		var pos_vec = Vector2.ZERO
		pos_vec.x = slot % int(INV_SIZE.x)
		pos_vec.y = (slot - pos_vec.x) / int(INV_SIZE.x)
		$Holder/SlotBlocker.position = pos_vec * ITEM_SIZE + Vector2.ONE
		$Holder/SlotBlocker.position += Vector2(0,14) if slot >= (INV_SIZE.y - 1) * INV_SIZE.x else Vector2.ZERO
		$Holder/SlotBlocker.show()
	
	else:
		$Holder/SlotBlocker.hide()

#Stops holding a certain item
func __free_held_item() -> BaseItem:
	var temp = held_item
	temp.hold(false)
	held_item = null
	return temp

#Grabs item
func __grab_item(item : BaseItem):
	if delete_list.has(item):
		return
	held_item = item
	item.hold(true)
	_block_slot(inv.find(held_item), true)

func __scroll_selection(value : int):
	
	selection += value
	
	if selection < 0:
		selection = INV_SIZE.x - 1
	if selection == INV_SIZE.x:
		selection = 0
	
	$Holder/Selection.position = Vector2(selection * ITEM_SIZE.x + 1, 175)
	emit_signal("selected_changed")

func get_selected():
	return inv.get_slot(selection + INV_SIZE.x * (INV_SIZE.y-1))

func toggle_bag():
	$Bag.visible = !$Bag.visible
	for i in range(INV_SIZE.x * (INV_SIZE.y-1)):
		if inv.get_slot(i) != null:
			inv.get_slot(i).node.visible = $Bag.visible
	$Holder/SlotBlocker.visible = $Bag.visible
	if !$Bag.visible and held_item != null:
		var item = held_item
		held_item = null
		item.hold(false)
		_move_item_to_slot(item, -1)

func get_equipment():
	var ret = []
	for i in range(INV_SIZE.y-1):
		ret.append(inv.get_slot((i+1) * INV_SIZE.x - 1))
	return ret

func equip():	
	dequip()	
	for i in get_equipment():
		if i != null:
			i.equip()

func dequip():
	#get_parent().get_parent().get_parent().get_node("Sprites/Torso/Helm").texture = null
	for i in inv.items:
		if i != null and (i.type == "armor" or i.type == "praecis"):
			i.dequip()

func move_praecis(delta):
	var praecis = inv.get_slot(INV_SIZE.x * (INV_SIZE.y-1) - 1)
	if praecis != null:
		praecis.move(delta)

func equiped_praecis():
	return inv.get_slot(24)

func unlock_item(item: int):
	if not item in unlocked_items:
		unlocked_items.append(item)
		save()
