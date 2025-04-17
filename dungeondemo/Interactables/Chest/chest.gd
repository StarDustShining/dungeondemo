@tool
class_name Chest extends Node

@export var item_data : ItemData : set = SetItemData
@export var quantity : int=1 : set = SetQuantity

var is_open: bool = false
@onready var item_sprite: Sprite2D = $ItemSprite
@onready var label: Label = $ItemSprite/Label
@onready var interact_area: Area2D = $Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var is_open_data: PersistentDataHandler = $IsOpen


func _ready() -> void:
	UpdateTexture()
	UpdateLabel()
	if Engine.is_editor_hint():
		return
	interact_area.area_entered.connect(OnAreaEnter)
	interact_area.area_exited.connect(OnAreaExit)
	is_open_data.data_loaded.connect(SetChestState)
	SetChestState()

func SetChestState() -> void:
	is_open = is_open_data.value
	if is_open:
		animation_player.play("opened")
	else:
		animation_player.play("closed")

func player_interact() -> void:
	if is_open:
		return
	is_open = true
	is_open_data.set_value()
	animation_player.play("open_chest")

	if item_data and quantity > 0:
		PlayerManager.INVENTORY_DATA.add_item( item_data, quantity )
	else:
		printerr("No Items in Chest!")
		push_error("No Items in Chest! Chest Name: ", name)
	pass


func OnAreaEnter(_a: Area2D) -> void:
	PlayerManager.interact_pressed.connect(player_interact)

func OnAreaExit(_a: Area2D) -> void:
	PlayerManager.interact_pressed.disconnect(player_interact)

func SetItemData(value: ItemData) -> void:
	item_data = value
	UpdateTexture()

func SetQuantity(value: int) -> void:
	quantity = value
	UpdateLabel()

func UpdateTexture() -> void:
	if item_data and item_sprite:
		item_sprite.texture = item_data.texture

func UpdateLabel() -> void:
	if label:
		if quantity <= 1:
			label.text = ""
		else:
			label.text = "x" + str( quantity )
