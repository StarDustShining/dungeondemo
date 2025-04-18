extends Node2D

const START_LEVEL : String = "res://Level/TrebuchetLevel/trebuchet_level.tscn"

@export var music : AudioStream
@export var button_focus_audio : AudioStream
@export var button_press_audio : AudioStream

@onready var audio_stream_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var button_new: Button = $CanvasLayer/Control/ButtonNew
@onready var button_continue: Button = $CanvasLayer/Control/ButtonContinue
@onready var video_player: VideoStreamPlayer = $CanvasLayer/Control/VideoStreamPlayer
@onready var splash_player: VideoStreamPlayer = $CanvasLayer/Control/SplashPlayer

func _ready() -> void:
	get_tree().paused = true
	PlayerManager.player.visible=false
	PlayerHud.visible = false
	BackpackMenu.visible=false
	PauseMenu.process_mode = Node.PROCESS_MODE_DISABLED
	if SaveManager.get_save_file() == null:
		button_continue.disabled = true
		button_continue.visible = false
	
	# 播放 splash_player
	splash_player.play()
	splash_player.finished.connect(on_splash_finished)
	
func setup_title_screen() -> void:
	button_new.pressed.connect( start_game )
	button_continue.pressed.connect( load_game )
	button_new.grab_focus()
	
	button_new.focus_entered.connect( play_audio.bind( button_focus_audio ) )
	button_continue.focus_entered.connect( play_audio.bind( button_focus_audio ) )
	
func start_game() -> void:
	print("start!")
	play_audio(button_press_audio)
	video_player.play()

func exit_title_screen() -> void:
	PlayerHud.visible = true
	PauseMenu.process_mode = Node.PROCESS_MODE_ALWAYS
	BackpackMenu.visible=true
	self.queue_free()

func load_game() -> void:
	play_audio( button_press_audio )
	SaveManager.LoadGame()

func play_audio( _a : AudioStream ) -> void:
	audio_stream_player.stream = _a
	audio_stream_player.play()

func on_video_finished() -> void:
	LevelManager.load_new_level(START_LEVEL, "", Vector2.ZERO)
	exit_title_screen()

# 添加 splash 播放完成后的处理函数
func on_splash_finished() -> void:
	# 隐藏 splash_player
	splash_player.visible = false
	
	# 设置其他内容
	setup_title_screen()
	video_player.finished.connect(on_video_finished)
	LevelManager.level_load_started.connect( exit_title_screen )
	
	# 如果需要播放背景音乐，可以在这里播放
	if music:
		audio_stream_player.stream = music
		audio_stream_player.play()
