extends Node

signal level_load_started
signal level_loaded
signal tilemap_bounds_changed( bounds : Array[ Vector2 ] )

var current_tilemap_bounds : Array[ Vector2 ]
var target_transition : String
var position_offset : Vector2
var is_loading = false


func _ready() -> void:
	await get_tree().process_frame
	level_loaded.emit()



func change_tilemap_bounds( bounds : Array[ Vector2 ] ) -> void:
	current_tilemap_bounds = bounds
	tilemap_bounds_changed.emit( bounds )


func load_new_level(
		level_path : String,
		_target_transition : String,
		_position_offset : Vector2
) -> void:
	print("Loading new level...")
	print("调用栈信息:")
	print_stack()
	#if is_loading:
		#return
	#is_loading = true
	
	get_tree().paused = true
	target_transition = _target_transition
	position_offset = _position_offset
	
	await SceneTransition.FadeOut()
	
	level_load_started.emit()
	
	await get_tree().process_frame
	
	get_tree().change_scene_to_file( level_path )
	
	await SceneTransition.FadeIn()
	
	get_tree().paused = false
	
	await get_tree().process_frame
	
	level_loaded.emit()
	
	pass
