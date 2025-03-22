@tool
class_name Chest extends Node

@export var item_data : ItemData : set = SetItemData
@export var quantity : int=1 : set = SetQuantity

var is_open: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $ItemSprite/Label
@onready var interact_area: Area2D = $Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var is_open_data: PersistentDataHandler = $IsOpen
#@onready var choice_panel: CanvasLayer = $ChoicePanel


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

	## 确保 `choice_panel` 存在
	#if choice_panel == null:
		#print_debug("Error: choice_panel is null!")
		#return
#
	## 确保信号未重复连接
	#if not choice_panel.is_connected("answer_correct", Callable(self, "_on_answer_correct")):
		#choice_panel.connect("answer_correct", Callable(self, "_on_answer_correct"))
		#print_debug("Connected answer_correct signal!")
#
	## 显示选择题
	#choice_panel.show_question("What is 2 + 2?", ["2", "3", "4", "5"], 2)

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
	if item_data and sprite:
		sprite.texture = item_data.texture

func UpdateLabel() -> void:
	if label:
		label.text = "" if quantity <= 1 else "x" + str(quantity)

# 玩家答对后触发的逻辑
func _on_answer_correct() -> void:
	print("You got the item!")  # ✅ 确保这里有输出
	if item_data and quantity > 0:
		PlayerManager.INVENTORY_DATA.add_item(item_data, quantity)
		animation_player.play("opened")
	else:
		print("No Items in Chest!")
