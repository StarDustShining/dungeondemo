extends Node

signal level_load_started
signal minigame_load_started
signal level_loaded
signal minigame_loaded
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

func load_minigame(minigame_path: String) -> Node:
	if is_loading:
		return null
	is_loading = true

	minigame_load_started.emit()
	get_tree().paused = true

	await SceneTransition.FadeOut()

	# 加载场景并检查是否成功
	var minigame_scene = load(minigame_path)
	if minigame_scene == null:
		print("错误: 无法加载小游戏场景，路径可能错误: ", minigame_path)
		is_loading = false
		return null

	# 实例化场景
	var minigame_instance = minigame_scene.instantiate()
	get_tree().root.add_child(minigame_instance)  # 直接添加到根节点
	PhysicsServer2D.set_active(true)

	# 检查信号是否存在
	if not minigame_instance.has_signal("minigame_finished"):
		print("错误: 加载的小游戏没有 minigame_finished 信号")
		is_loading = false
		return null

	await SceneTransition.FadeIn()

	# 等待小游戏完成
	await minigame_instance.minigame_finished

	# 在小游戏完成后隐藏它，而不是销毁
	minigame_instance.visible = false

	# 触发加载完成信号
	minigame_loaded.emit()

	get_tree().paused = false
	is_loading = false

	# 返回场景实例
	return minigame_instance
