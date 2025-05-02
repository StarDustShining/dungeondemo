@tool
class_name ItemPickup extends Node2D

@export var item_data : ItemData : set = _set_item_data

@onready var area_2d: Area2D = $Area2D
@onready var sprite_2d: Sprite2D = $Sprite2D 
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _ready() -> void:
	# 更新纹理
	_update_texture()
	if Engine.is_editor_hint():
		return
	# 连接 body_entered 信号
	if area_2d:
		area_2d.body_entered.connect(_on_body_entered)
	else:
		print("错误: area_2d 未正确初始化。")

func _on_body_entered( b ) -> void:
	if b is Player:
		if item_data:
			#if PlayerManager.INVENTORY_DATA.add_item( item_data ) == true:
			var index = PlayerManager.INVENTORY_DATA.add_item(item_data) ###
			#if index >= 0: ###
			item_picked_up()
				#PlayerManager.inventory_ui_ref.update_inventory(index) ###
	pass

func item_picked_up() -> void:
	area_2d.body_entered.disconnect( _on_body_entered )
	audio_stream_player_2d.play()
	visible = false
	#picked_up.emit()
	await audio_stream_player_2d.finished
	queue_free()
	pass


func _set_item_data(value: ItemData) -> void:
	item_data = value
	_update_texture()
	pass


func _update_texture() -> void:
	if item_data and sprite_2d:
		sprite_2d.texture = item_data.texture
	pass
