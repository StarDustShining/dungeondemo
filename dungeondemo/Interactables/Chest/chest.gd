@tool
class_name Chest extends Node

@export var item_data : ItemData:set=SetItemData
@export var quantity : int=1:set=SetQuantity

var is_open: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $ItemSprite/Label
@onready var interact_area: Area2D = $Area2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var is_open_data: PersistentDataHandler = $IsOpen
@onready var choice_panel: CanvasLayer = $ChoicePanel


func _ready() -> void:
	UpdateTexture()
	UpdateLabel()
	if Engine.is_editor_hint():
		return
	interact_area.area_entered.connect(OnAreaEnter)
	interact_area.area_exited.connect(OnAreaExit)
	is_open_data.data_loaded.connect(SetChestState)
	SetChestState()
	pass

func SetChestState() -> void:
	is_open = is_open_data.value
	if is_open:
		animation_player.play("opened")
	else:
		animation_player.play("closed")

func player_interact() -> void:
	if is_open == true:
		return
	is_open = true
	is_open_data.set_value()
	animation_player.play("open_chest")
	
	# 设置选择题的内容和答案
	var question = "What is 2 + 2?"
	var answers = ["3", "4", "5"]
	var correct_answer_index = 2  # 选择正确答案的索引

	# 显示选择题
	choice_panel.show_question(question, answers, correct_answer_index)
	
	# 监听选择题的正确答案事件
	choice_panel.connect("answer_correct", Callable(self, "_on_answer_correct"))
	
	if item_data and quantity > 0:
		print("You have got a new item!")
		#PlayerManager.INVENTORY_DATA.add_item( item_data, quantity )
	else:
		printerr("No Items in Chest!")
		push_error("No Items in Chest! Chest Name: ", name)
	pass


func OnAreaEnter(_a: Area2D) -> void:
	PlayerManager.interact_pressed.connect(player_interact)
	pass


func OnAreaExit(_a: Area2D) -> void:
	PlayerManager.interact_pressed.disconnect(player_interact)
	pass

func SetItemData(value: ItemData) -> void:
	item_data = value
	UpdateTexture()
	pass

func SetQuantity(value: int) -> void:
	quantity = value
	UpdateLabel()
	pass

func UpdateTexture() -> void:
	if item_data and sprite:
		sprite.texture = item_data.texture


func UpdateLabel() -> void:
	if label:
		if quantity <= 1:
			label.text = ""
		else:
			label.text = "x" + str(quantity)

# 当玩家答对问题时，给予奖励
func _on_answer_correct() -> void:
	print("You got the item!")
	if item_data and quantity > 0:
		PlayerManager.INVENTORY_DATA.add_item(item_data, quantity)
		# 在这里可以添加奖励UI，播放奖励音效等
		animation_player.play("opened")  # 播放宝箱打开动画
	else:
		print("No Items in Chest!")
