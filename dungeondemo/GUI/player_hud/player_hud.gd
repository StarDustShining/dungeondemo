extends CanvasLayer

#@export var button_focus_audio : AudioStream = preload( "res://title_scene/audio/menu_focus.wav" )
#@export var button_select_audio : AudioStream = preload( "res://title_scene/audio/menu_select.wav" )

var hearts : Array[ HeartGUI ] = []
@onready var game_over: Control = $GameOver
@onready var animation_player: AnimationPlayer = $GameOver/AnimationPlayer
@onready var title_button: Button = $GameOver/VBoxContainer/TitleButton
@onready var continue_button: Button = $GameOver/VBoxContainer/ContinueButton



#@onready var game_over : Control = $Control/GameOver
#@onready var continue_button: Button = $Control/GameOver/VBoxContainer/ContinueButton
#@onready var title_button: Button = $Control/GameOver/VBoxContainer/TitleButton
#@onready var animation_player: AnimationPlayer = $Control/GameOver/AnimationPlayer
#@onready var audio: AudioStreamPlayer = $AudioStreamPlayer
#
#@onready var boss_ui: Control = $Control/BossUI
#@onready var boss_hp_bar: TextureProgressBar = $Control/BossUI/TextureProgressBar
#@onready var boss_label: Label = $Control/BossUI/Label

#@onready var notification_ui : NotificationUI = $Control/Notification

func _ready():
	for child in $Control/HFlowContainer.get_children():
		if child is HeartGUI:
			hearts.append( child )
			child.visible = false
	hide_game_over_screen()
	continue_button.pressed.connect( load_game )
	title_button.pressed.connect( title_screen )
	LevelManager.level_load_started.connect( hide_game_over_screen )

	
	pass

func UpdateHp( _hp: int, _max_hp: int ) -> void:
	UpdateMaxHp( _max_hp )
	for i in _max_hp:
		UpdateHeart( i, _hp )
		pass
	pass

func UpdateHeart(_index: int, _hp: int) -> void:
	var _value: int = clampi(_hp - _index * 2, 0, 2)  # 计算当前心形图标的状态
	hearts[_index].value = _value  # 更新心形图标的状态

func UpdateMaxHp( _max_hp : int ) -> void:
	var _heart_count : int = roundi( _max_hp * 0.5 )
	for i in hearts.size():
		if i < _heart_count:
			hearts[i].visible = true
		else:
			hearts[i].visible = false
	pass


#
func show_game_over_screen() -> void:
	game_over.visible = true
	game_over.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var can_continue : bool = SaveManager.get_save_file() != null
	continue_button.visible = can_continue
	
	animation_player.play("show_game_over")
	await animation_player.animation_finished
	
	if can_continue == true:
		continue_button.grab_focus()
	else:
		title_button.grab_focus()
	#
#
#
func hide_game_over_screen() -> void:
	game_over.visible = false
	game_over.mouse_filter = Control.MOUSE_FILTER_IGNORE
	game_over.modulate = Color( 1,1,1,0 )

func load_game() -> void:
	await fade_to_black()
	SaveManager.load_game()


func title_screen() -> void:

	await fade_to_black()
	LevelManager.load_new_level( "res://title_scene/title_scene.tscn", "", Vector2.ZERO )


func fade_to_black() -> bool:
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
	PlayerManager.player.revive_player()
	return true
