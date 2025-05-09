extends Node

const SAVE_PATH = "user://"

signal game_loaded
signal game_saved

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

#func SaveGame() -> void:
	#UpdatePlayerData()
	#UpdateScenePath()
	#var file := FileAccess.open(SAVE_PATH + "save.sav", FileAccess.WRITE)
	#var save_json = JSON.stringify(current_save)
	#file.store_line(save_json)
	#file.close()  # 记得关闭文件
	#game_saved.emit()
	#pass

#func LoadGame() -> void:
	#var file := FileAccess.open(SAVE_PATH + "save.sav", FileAccess.READ)
	#var json := JSON.new()
	#json.parse(file.get_line())
	#var save_dict : Dictionary = json.get_data() as Dictionary
	#current_save = save_dict
	#file.close()  # 记得关闭文件
	#LevelManager.load_new_level(current_save.scene_path, "", Vector2.ZERO)
	#await LevelManager.level_load_started
	#PlayerManager.set_player_position(Vector2(current_save.player.pos_x, current_save.player.pos_y))
	#PlayerManager.set_health(current_save.player.hp, current_save.player.max_hp)
	#await LevelManager.level_loaded
	#game_loaded.emit()
	#pass
func get_save_file() -> FileAccess:
	return FileAccess.open( SAVE_PATH + "save.sav", FileAccess.READ )


func SaveGame() -> void:
	UpdatePlayerData()
	UpdateScenePath()
	UpdateItemData()
	#update_quest_data()
	var file := FileAccess.open( SAVE_PATH + "save.sav", FileAccess.WRITE )
	var save_json = JSON.stringify( current_save )
	file.store_line( save_json )
	game_saved.emit()
	pass
	
	
func LoadGame() -> void:
	var file := FileAccess.open( SAVE_PATH + "save.sav", FileAccess.READ )
	#var file := get_save_file()
	var json := JSON.new()
	json.parse( file.get_line() )
	var save_dict : Dictionary = json.get_data() as Dictionary
	current_save = save_dict
	
	LevelManager.load_new_level( current_save.scene_path, "", Vector2.ZERO )
	
	await LevelManager.level_load_started
	
	PlayerManager.set_player_position( Vector2( current_save.player.pos_x, current_save.player.pos_y ) )
	PlayerManager.set_health( current_save.player.hp, current_save.player.max_hp )
	
	#var p : Player = PlayerManager.player
	#p.level = current_save.player.level
	#p.xp = current_save.player.xp
	#p.attack = current_save.player.attack
	#p.defense = current_save.player.defense
	#
	#PlayerManager.INVENTORY_DATA.parse_save_data( current_save.items )
	#QuestManager.current_quests = current_save.quests
	
	await LevelManager.level_loaded
	
	game_loaded.emit()
	pass

func UpdatePlayerData() -> void:
	var p : Player = PlayerManager.player
	current_save.player.hp = p.hp
	current_save.player.max_hp = p.max_hp
	current_save.player.pos_x = p.global_position.x
	current_save.player.pos_y = p.global_position.y
	#current_save.player.level = p.level
	#current_save.player.xp = p.xp
	#current_save.player.attack = p.attack
	#current_save.player.defense = p.defense

func UpdateScenePath() -> void:
	var p : String = ""
	for c in get_tree().root.get_children():
		if c is Level:
			p = c.scene_file_path
	current_save.scene_path = p

func UpdateItemData() -> void:
	current_save.items = PlayerManager.INVENTORY_DATA.get_save_data()

#func UpdateQuestData() -> void:
	#current_save.quests = QuestManager.current_quests

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
