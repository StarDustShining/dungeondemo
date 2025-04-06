extends VBoxContainer

var ITEMS = Globals.ITEM_INFO

var craftable_indices_to_item_indices := {}
var unlockable_indices_to_item_indices := {}

@onready var player = get_parent().get_parent().get_parent()
@onready var inventory = get_node("../../Inventory")

@onready var craftable_item_list = $ScrollContainer/VBoxContainer/Craftable
@onready var unlocked_item_list = $ScrollContainer/VBoxContainer/Unlocked
@onready var ingredients_list = $IngredientList
@onready var colorrect = get_node("..")

var crafting_station := ""

var selected_item_idx := -1

func _ready():
	
	hide()
	refresh_items()
	

func hide():
	colorrect.hide()
	super.hide()
func show():
	colorrect.show()
	super.show()

func register_station(station: String):
	crafting_station = station
	refresh_items()


func refresh_items():
	craftable_item_list.clear()
	unlocked_item_list.clear()
	ingredients_list.clear()
	
	var i := 0
	var j := 0
	for item_idx in inventory.unlocked_items:
		match can_craft(item_idx):
			
			CraftReturn.Pass:
				craftable_indices_to_item_indices[i] = item_idx
				craftable_item_list.add_item(ITEMS[item_idx].name, ITEMS[item_idx].spri)
				i += 1
			CraftReturn.NotEnoughMaterials:
				unlockable_indices_to_item_indices[j] = item_idx
				unlocked_item_list.add_item(ITEMS[item_idx].name, ITEMS[item_idx].spri)
				j += 1
			
		

enum CraftReturn {
	Pass,
	NoRecipe,
	WrongStation,
	NotEnoughMaterials,
}
func can_craft(item_idx: int) -> int:
	var has_all_ingredients := false
	
	# IMPLEMENT CRAFTING MECHANISM HERE
	
	
	if not Globals.ITEM_INFO[item_idx].has("craft"):
		return CraftReturn.NoRecipe
	
	var craft_dict: Dictionary = Globals.ITEM_INFO[item_idx].craft
	if not craft_dict.has(crafting_station):
		return CraftReturn.WrongStation
	
	var ingredient_dict: Dictionary = craft_dict[crafting_station]
	
	# checks all ingredients to make sure player has items
	for item_idx in ingredient_dict:
		var amount_required: int = ingredient_dict[item_idx]
		var amount_has: int = inventory._check_amount_with_id(item_idx)
		if amount_has < amount_required:
			# if player doesn't, return false
			return CraftReturn.NotEnoughMaterials
	
	return CraftReturn.Pass
	

func craft_item(index: int):
	
	var err = can_craft(index)
	if err != CraftReturn.Pass:
		printerr("Crafting Uncraftable Item with return " + str(err))
		return
	
	var ingredient_dict: Dictionary = Globals.ITEM_INFO[index].craft[crafting_station]
	for required_item_idx in ingredient_dict:
		inventory.remove_with_id(required_item_idx, ingredient_dict[required_item_idx])
	
	inventory.pickup_item(Globals.create_item(index, 1, player))
	refresh_items()
	show_ingredients(index)


func ItemList_item_selected(index: int, type: String):
	
	match type:
		"Craftable":
			$CraftButton.modulate = Color(1, 1, 1)
		"Unlockable":
			$CraftButton.modulate = Color(0.660156, 0.660156, 0.660156)
	
	var indices_to_item_indices: Dictionary = get(type.to_lower() + "_indices_to_item_indices")
	
	if not indices_to_item_indices.has(index): 
		printerr("selected invalid item (CraftingItem local_index = "+str(index)+")")
		return
	
	var item_idx: int = indices_to_item_indices[index]
	selected_item_idx = item_idx
	
	show_ingredients(item_idx)

func show_ingredients(item_idx):
	ingredients_list.clear()
	for ingredient in Globals.ITEM_INFO[item_idx].craft[crafting_station]:
		var amount = Globals.ITEM_INFO[item_idx].craft[crafting_station][ingredient]
		ingredients_list.add_item(str(amount) ,Globals.ITEM_INFO[ingredient].spri, true)
	


func _on_CraftButton_pressed():
	if selected_item_idx != -1:
		craft_item(selected_item_idx)
