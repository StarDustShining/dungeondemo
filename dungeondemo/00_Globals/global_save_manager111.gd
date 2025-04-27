extends Node

signal game_loaded
signal game_saved

@onready var player:Player=PlayerManager.player

var current_save : Dictionary = {
	scene_path = "",
	player = {
		#level = 1,
		#xp = 0,
		hp = 1,
		max_hp = 1,
		#attack = 1,
		#defense = 1,
		pos_x = 0,
		pos_y = 0
	},
	items = [],
	persistence = [],
}

func SaveGame() -> void:
	var data=SceneData.new()
	data.player_position=player.global_position
	data.player_hp=player.hp
	data.player_max_hp=player.max_hp
	data.player_direction=player.direction
	
	var enemies=get_tree().get_nodes_in_group("Enemy")
	for enemy in enemies:
		var enemy_sence=PackedScene.new()
		enemy_sence.pack(enemy)
		data.enemy_array.append(enemy_sence)
	
	var mirrors=get_tree().get_nodes_in_group("Mirror")
	for mirror in mirrors:
		var mirror_sence=PackedScene.new()
		mirror_sence.pack(mirror)
		data.mirror_array.append(mirror_sence)
	
	var magnets=get_tree().get_nodes_in_group("Magnet")
	for magnet in magnets:
		var magnet_sence=PackedScene.new()
		magnet_sence.pack(magnet)
		data.magent_array.append(magnet_sence)
	
	var chests=get_tree().get_nodes_in_group("Chest")
	for chest in chests:
		var chest_sence=PackedScene.new()
		chest_sence.pack(chest)
		data.chest_array.append(chest_sence)
	
	ResourceSaver.save(data,"user://scene_data.tres")
	game_saved.emit()
	print("Saved!")
	
func LoadGame() -> void:
	var data=ResourceLoader.load("user://scene_data.tres") as SceneData
	#await LevelManager.level_load_started
	player.global_position=data.player_position
	player.hp=data.player_hp
	player.max_hp=data.player_max_hp
	player.direction=data.player_direction
	
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		enemy.queue_free()
	for mirror in get_tree().get_nodes_in_group("Mirror"):
		mirror.queue_free()
	for magnet in get_tree().get_nodes_in_group("Magnet"):
		magnet.queue_free()
	for chest in get_tree().get_nodes_in_group("Chest"):
		chest.queue_free()
	
	for enemy in data.enemy_array:
		var enemy_node=enemy.instantiate()
		get_tree().current_scene.add_child(enemy_node)
	for mirror in data.mirror_array:
		var mirror_node=mirror.instantiate()
		get_tree().current_scene.add_child(mirror_node)
	for magnet in data.magent_array:
		var magnet_node=magnet.instantiate()
		get_tree().current_scene.add_child(magnet)
	for chest in data.chest_array:
		var chest_node=chest.instantiate()
		get_tree().current_scene.add_child(chest_node)
	#await LevelManager.level_loaded
	
	await get_tree().create_timer(0.1).timeout
	game_loaded.emit()
	print("Loaded!")
	pass

func UpdatePlayerData() -> void:
	pass


func UpdateScenePath() -> void:
	var p : String = ""
	for c in get_tree().root.get_children():
		if c is Level:
			p = c.scene_file_path

func UpdateItemData() -> void:
	#current_save.items = PlayerManager.INVENTORY_DATA.get_save_data()
	pass

func AddPersistentValue( value : String ) -> void:
	if CheckPersistentValue( value ) == false:
		current_save.persistence.append( value )
	pass
#
#

func RemovePersistentValue( value : String ) -> void:
	var p = current_save.persistence as Array
	p.erase( value )
	pass

#
func CheckPersistentValue( value : String ) -> bool:
	var p = current_save.persistence as Array
	return p.has( value )
