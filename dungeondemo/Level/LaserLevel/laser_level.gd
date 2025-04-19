class_name LaserLevel extends Node2D

@onready var night_pearl: Node2D = $NightPearl
@onready var receiver: Node2D = $Receiver
@onready var stone_door: Node2D = $StoneDoor
@onready var laser: Node2D = $NightPearl/Laser
@onready var video_player: VideoStreamPlayer = $CanvasLayer/VideoStreamPlayer

# 添加一个标志变量来跟踪动画是否已经播放过
var stone_door_opened = false

# 添加一个标志变量来跟踪视频是否正在播放
var video_playing = false

func _ready() -> void:
	# 强制设置玩家位置在(1500, 200)
	await get_tree().create_timer(0.1).timeout
	if PlayerManager.player and is_instance_valid(PlayerManager.player):
		PlayerManager.player.global_position = Vector2(400, 128)
		
	self.y_sort_enabled = true
	PlayerManager.set_as_parent(self)
	LevelManager.level_load_started.connect(_free_level)
	LevelManager.minigame_load_started.connect(_pause_level)
	
	# 连接 Laser 的 block_area_detected 信号
	laser.receive_area_detected.connect(_on_Laser_receive_area_detected)
	
	# 连接 video_player 的 finished 信号
	video_player.finished.connect(_on_video_player_finished)


func _on_Laser_receive_area_detected():
	# 检查动画是否已经播放过
	if not stone_door_opened:
		# 检查视频是否正在播放
		if not video_playing:
			print("Playing video...")
			video_player.play()
			video_playing = true

func _on_video_player_finished():
	print("Video finished, playing stone door animation...")
	# 播放 StoneDoor 的 "Open" 动画
	var animation_player = stone_door.get_node("AnimationPlayer")
	animation_player.play("Open")
	# 设置标志变量为 true，表示动画已经播放过
	stone_door_opened = true
	# 重置视频播放标志变量
	video_playing = false

func _free_level() -> void:
	PlayerManager.unparent_player(self)
	queue_free()

func _pause_level() -> void:
	pass
