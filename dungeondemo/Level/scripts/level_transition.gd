@tool
class_name LevelTransition extends Area2D

signal entered_from_here

enum SIDE { LEFT, RIGHT, TOP, BOTTOM }

@export_file( "*.tscn" ) var level
@export var target_transition_area : String = "LevelTransition"
@export var center_player : bool = false

@export_category("Collision Area Settings")

@export_range( 1, 12, 1, "or_greater") var size : int = 3 :
	set( _v ):
		size = _v
		_update_area()

@export var side: SIDE = SIDE.LEFT :
	set( _v ):
		side = _v
		_update_area()

@export var snap_to_grid : bool = false :
	set ( _v ):
		_snap_to_grid()

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	_update_area()
	if Engine.is_editor_hint():
		return
	
	monitoring = false
	_place_player()
	
	await LevelManager.level_loaded
	await get_tree().physics_frame
	await get_tree().physics_frame

	monitoring = true

	# 断开之前的连接，确保不会重复连接
	if area_entered.is_connected(_player_entered):
		area_entered.disconnect(_player_entered)
	area_entered.connect(_player_entered)

func _player_entered(_p: Node2D) -> void:
	# 如果是 player，保存其血量到全局
	#if _p.has_method("UpdateHp") and _p.get("hp") != null and _p.get("max_hp") != null:
		#var player_manager = get_node_or_null("/root/PlayerManager")
		#if player_manager and player_manager.has_method("set_health"):
			#player_manager.set_health(_p.hp, _p.max_hp)
			#print("保存玩家血量:", _p.hp, "/", _p.max_hp)
	# 短暂等待，防止重复触发
	await get_tree().create_timer(0.5).timeout
	LevelManager.load_new_level(level, target_transition_area, get_offset())
	pass


func _place_player() -> void:
	if name != LevelManager.target_transition:
		return
	var offset = LevelManager.position_offset
	# 让玩家出生点远离传送门一格
	match side:
		SIDE.LEFT:
			offset.x += 64
		SIDE.RIGHT:
			offset.x -= 64
		SIDE.TOP:
			offset.y += 64
		SIDE.BOTTOM:
			offset.y -= 64
	PlayerManager.set_player_position(global_position + offset)
	entered_from_here.emit()

func get_offset() -> Vector2:
	var offset : Vector2 = Vector2.ZERO
	var player_pos = PlayerManager.player.global_position
	
	if side == SIDE.LEFT or side == SIDE.RIGHT:
		if center_player == true:
			offset.y = 0
		else:
			offset.y = player_pos.y - global_position.y
		offset.x = 32
		if side == SIDE.LEFT:
			offset.x *= -1
	else:
		if center_player == true:
			offset.x = 0
		else:
			offset.x = player_pos.x - global_position.x
		offset.y = 32
		if side == SIDE.TOP:
			offset.y *= -1

	return offset

func _update_area() -> void:
	var new_rect : Vector2 = Vector2( 32, 32 )
	var new_position : Vector2 = Vector2.ZERO
	
	if side == SIDE.TOP:
		new_rect.x *= size
		new_position.y -= 48
	elif side == SIDE.BOTTOM:
		new_rect.x *= size
		new_position.y += 48
	elif side == SIDE.LEFT:
		new_rect.y *= size
		new_position.x -= 48
	elif side == SIDE.RIGHT:
		new_rect.y *= size
		new_position.x += 48
	
	if collision_shape == null:
		collision_shape = get_node("CollisionShape2D")
	
	collision_shape.shape.size = new_rect
	collision_shape.position = new_position


func _snap_to_grid() -> void:
	position.x = round( position.x / 16 ) * 16
	position.y = round( position.y / 16 ) * 16
