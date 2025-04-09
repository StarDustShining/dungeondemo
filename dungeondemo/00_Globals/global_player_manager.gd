extends Node

const PLAYER = preload("res://Player/Player.tscn")
const INVENTORY_DATA :  = preload("res://GUI/inventory/player_inventory.tres")

signal camera_shook( trauma : float )
signal interact_pressed
signal player_leveled_up

var interact_handled : bool = true
var player : Player
var player_spawned : bool = false

#var level_requirements = [ 0, 50, 100, 200, 400, 800, 1500, 3000, 6000, 12000, 2500 ]
var level_requirements = [ 0, 5, 10, 20, 40 ]


func _ready() -> void:
	# 检查当前场景，更精确地查找Down相关场景
	var current_scene = get_tree().current_scene
	var scene_path = current_scene.scene_file_path if current_scene else ""
	
	# 如果场景路径或场景名包含Down，则不生成全局玩家
	if scene_path.contains("Down") or scene_path.contains("down") or \
	   (current_scene and (current_scene.name.contains("Down") or current_scene.name.contains("down"))):
		print("检测到Down场景，禁用全局玩家生成: " + scene_path)
		# 在Down场景中，我们不生成全局玩家
		player_spawned = true
		# 确保没有已存在的玩家实例
		if player:
			player.queue_free()
			player = null
		return
	
	# 对于其他场景，正常生成全局玩家
	print("非Down场景，正常生成全局玩家")
	add_player_instance()
	await get_tree().create_timer(0.2).timeout
	player_spawned = true



func add_player_instance() -> void:
	player = PLAYER.instantiate()
	add_child( player )
	pass



func set_health( hp: int, max_hp: int ) -> void:
	# 确保玩家存在并且场景不是Down场景
	if is_down_scene() or not player or not is_instance_valid(player):
		return
		
	player.max_hp = max_hp
	player.hp = hp
	player.UpdateHp( 0 )



func reward_xp( _xp : int ) -> void:
	player.xp += _xp
	# check for level advancement
	check_for_level_advance()


# Check for level advance, recursively.
# A recursive function will call itself under certain conditions,
# and will NOT call itself under other conditions, known as a base condition.
# An exit or base condition that stops the recursion is essential, 
# otherwise the function will call itself indefinitely and lock up the program 
func check_for_level_advance() -> void:
	if player.level >= level_requirements.size():
		return
	if player.xp >= level_requirements[ player.level ]:
		player.level += 1
		player.attack += 1
		player.defense += 1
		player_leveled_up.emit()
		check_for_level_advance()
	pass




func set_player_position( _new_pos : Vector2 ) -> void:
	player.global_position = _new_pos
	pass



# 检查当前场景是否为Down相关场景
func is_down_scene() -> bool:
	var current_scene = get_tree().current_scene
	var scene_path = current_scene.scene_file_path if current_scene else ""
	
	return scene_path.contains("Down") or scene_path.contains("down") or \
		(current_scene and (current_scene.name.contains("Down") or current_scene.name.contains("down")))



# 修改set_as_parent函数，在Down场景中不执行
func set_as_parent(_p : Node2D) -> void:
	# 在Down场景中不执行此函数
	if is_down_scene():
		print("当前为Down场景，不执行set_as_parent")
		return
		
	print("Setting player parent")
	if player and player.get_parent():
		player.get_parent().remove_child(player)
	if player:
		_p.add_child(player)



# 修改interact函数，添加场景检测
func interact() -> void:
	interact_handled = false
	interact_pressed.emit()



func shake_camera( trauma : float = 1 ) -> void:
	camera_shook.emit( clampi( trauma, 0, 3 ) )



# 修改unparent_player函数，添加场景检测
func unparent_player(_p : Node2D) -> void:
	# 在Down场景中不执行此函数
	if is_down_scene():
		print("当前为Down场景，不执行unparent_player")
		return
		
	print("Unparenting player")
	if player and player.get_parent() == _p:
		_p.remove_child(player)


func play_audio( _audio : AudioStream ) -> void:
	if player and is_instance_valid(player) and player.has_method("play"):
		player.audio.stream = _audio
		player.audio.play()
