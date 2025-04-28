class_name PersistentDataHandler extends Node

signal data_loaded
var value : bool = false


func _ready() -> void:
	if not LevelManager.level_loaded.is_connected(_on_level_loaded):
		LevelManager.level_loaded.connect(_on_level_loaded)


func _on_level_loaded() -> void:
	get_value()

func set_value() -> void:
	SaveManager.AddPersistentValue( _get_name() )
	pass


func get_value() -> void:
	value = SaveManager.CheckPersistentValue( _get_name() )
	data_loaded.emit()
	pass


func remove_value() -> void:
	SaveManager.RemovePersistentValue( _get_name() )
	pass


func _get_name() -> String:
	return get_tree().current_scene.scene_file_path + "/" + get_parent().name + "/" + name
