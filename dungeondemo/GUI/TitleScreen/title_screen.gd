extends Node2D

const START_LEVEL : String = "res://Level/LaserLevel/laser_level.tscn"

@export var music : AudioStream
@export var button_focus_audio : AudioStream
@export var button_press_audio : AudioStream

@onready var audio_stream_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var button_new: Button = $CanvasLayer/Control/ButtonNew
@onready var button_continue: Button = $CanvasLayer/Control/ButtonContinue


func _ready() -> void:
	get_tree().paused = true
	PlayerHud.visible = false
	BackpackMenu.visible=false
	PauseMenu.process_mode = Node.PROCESS_MODE_DISABLED
	if SaveManager.get_save_file() == null:
		button_continue.disabled = true
		button_continue.visible = false
	#$CanvasLayer/SplashScene.finished.connect( setup_title_screen )
	LevelManager.level_load_started.connect( exit_title_screen )

func setup_title_screen() -> void:
	button_new.pressed.connect( start_game )
	button_continue.pressed.connect( load_game )
	button_new.grab_focus()
	
	button_new.focus_entered.connect( play_audio.bind( button_focus_audio ) )
	button_continue.focus_entered.connect( play_audio.bind( button_focus_audio ) )
	
	pass

func start_game() -> void:
	print("start!")
	play_audio( button_press_audio )
	LevelManager.load_new_level( START_LEVEL, "", Vector2.ZERO )
	pass

func exit_title_screen() -> void:
	PlayerHud.visible = true
	PauseMenu.process_mode = Node.PROCESS_MODE_ALWAYS
	BackpackMenu.visible=false
	self.queue_free()
	pass

func load_game() -> void:
	play_audio( button_press_audio )
	SaveManager.LoadGame()
	pass

func play_audio( _a : AudioStream ) -> void:
	audio_stream_player.stream = _a
	audio_stream_player.play()
