extends Node

signal game_loaded
signal game_saved

@onready var player:Player=PlayerManager.player

var current_save : Dictionary = {
	scene_path = "",
	persistence = [],
}

func get_save_file() -> Resource:
	var save_path = "user://scene_data.tres"
	if ResourceLoader.exists(save_path):
		var save_data = ResourceLoader.load(save_path) as SceneData
		if save_data:
			return save_data
		else:
			print("错误: 无法加载保存文件")
	else:
		print("错误: 保存文件不存在")
	return null

func SaveGame() -> void:
	var data=SceneData.new()
	data.player_position=player.global_position
	data.player_hp=player.hp
	data.player_max_hp=player.max_hp
	data.player_direction=player.direction
	
	# 记录当前场景路径
	data.scene_path = get_tree().current_scene.scene_file_path
	
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
	
	# 检查当前场景路径是否匹配
	if data.scene_path != get_tree().current_scene.scene_file_path:
		print("错误: 场景路径不匹配，无法加载状态")
		return
	
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
