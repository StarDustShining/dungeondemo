extends CanvasLayer

signal shown
signal hidden

@onready var button_save: Button = $Control/VBoxContainer/Button_Save
@onready var button_load: Button = $Control/VBoxContainer/Button_Load

var is_paused : bool = false

func _ready() -> void:
	HidePauseMenu()
	button_save.pressed.connect( _on_save_pressed )
	button_load.pressed.connect( _on_load_pressed )
	#button_quit.pressed.connect( _on_quit_pressed )
	pass



func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("暂停"):
		if is_paused == false:
			ShowPauseMenu()
			#if DialogSystem.is_active:
				#return
		else:
			HidePauseMenu()
		get_viewport().set_input_as_handled()
	#
	#if is_paused:
		#if event.is_action_pressed("right_bumper"):
			#change_tab( 1 )
		#elif event.is_action_pressed("left_bumper"):
			#change_tab( -1 )
#
#
func ShowPauseMenu() -> void:
	get_tree().paused = true
	visible = true
	is_paused = true
	button_save.grab_focus()
	shown.emit()

func HidePauseMenu() -> void:
	get_tree().paused = false
	visible = false
	is_paused = false
	hidden.emit()

func _on_save_pressed() -> void:
	if is_paused == false:
		return
	SaveManager.SaveGame()
	HidePauseMenu()
	pass


func _on_load_pressed() -> void:
	if is_paused == false:
		return
	SaveManager.LoadGame()
	await LevelManager.level_load_started
	HidePauseMenu()
	pass

#func _on_quit_pressed() -> void:
	#get_tree().quit()
#
#
#
#func focused_item_changed( slot : SlotData ) -> void:
	#if slot:
		#if slot.item_data:
			#update_item_description( slot.item_data.description )
			#preview_stats( slot.item_data )
	#else:
		#update_item_description("")
		#preview_stats( null )
#
#
#
#
#
#func change_tab( _i : int = 1 ) -> void:
	#tab_container.current_tab = wrapi(
			#tab_container.current_tab + _i,
			#0,
			#tab_container.get_tab_count()
		#)
	#tab_container.get_tab_bar().grab_focus()
#
#
#func preview_stats( item : ItemData ) -> void:
	#preview_stats_changed.emit( item )
	#pass
