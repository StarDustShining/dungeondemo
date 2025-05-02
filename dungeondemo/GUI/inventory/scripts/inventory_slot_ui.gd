class_name InventorySlotUI extends Button

var slot_data : SlotData : set = set_slot_data
###
var image_visible := false
var center_image: TextureRect = null

@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label



func _ready() -> void:
	texture_rect.texture = null
	label.text = ""
	focus_entered.connect(item_focused)
	focus_exited.connect(item_unfocused)
	pressed.connect( item_pressed )


func set_slot_data(value: SlotData) -> void:
	slot_data = value
	if slot_data == null:
		return
	texture_rect.texture = slot_data.item_data.texture
	label.text = str(slot_data.quantity)

func item_focused() -> void:
	if slot_data != null:
		if slot_data.item_data != null:
			BackpackMenu.update_item_description(slot_data.item_data.description)
	pass

func item_unfocused() -> void:
	BackpackMenu.update_item_description("")
	pass

func _on_request_show_image(path: String) -> void:
	if not center_image:
		push_error("找不到 CenterImage 节点！")
		return

	if not center_image.texture:
		var tex = load(path)
		if tex:
			center_image.texture = tex

	image_visible = !image_visible
	center_image.visible = image_visible



func item_pressed() -> void:
	if slot_data: #and outside_drag_threshold() == false:
		if slot_data.item_data:
			var item = slot_data.item_data
			
			for effect in item.effects:
				if effect is ItemEffectRead:
					print("使用了卷轴")
					var cb = Callable(self, "_on_request_show_image")
					effect.connect("request_show_image", cb)
					if not effect.is_connected("request_show_image", cb):
						effect.connect("request_show_image", cb)
			
			var was_used = item.use()
			if was_used == false:
				return
			slot_data.quantity -= 1
			
			if slot_data == null:
				return
			label.text = str( slot_data.quantity )
