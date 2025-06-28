class_name ChimeBellLevel extends Node2D

@onready var night_pearl: Node2D = $NightPearl
@onready var stone_door: Node2D = $StoneDoor
@onready var skeleton_video: VideoStreamPlayer = $CanvasLayer/SkeletonVideo
@onready var seisomgraph_video: VideoStreamPlayer = $CanvasLayer/SeisomgraphVideo
@onready var bell_player: VideoStreamPlayer = $CanvasLayer/BellPlayer

var stone_door_opened = false
var skeleton_monster_scene:PackedScene=preload("res://Enemy/骷髅/skeletonMonster.tscn")
var game03_result: int = -1  # -1=未完成, 0=失败, 1=成功


func _ready() -> void:
	self.y_sort_enabled = true
	PlayerManager.set_as_parent(self)
	LevelManager.level_load_started.connect(_free_level)
	LevelManager.minigame_load_started.connect(_pause_level)
	PlayerManager.player.top_down = false
	PlayerManager.player._ready()  # 确保 Player 的 _ready() 函数被调用

func _process(delta):
	if game03_result == 0:
		game03_result = -1  # 防止重复
		on_game03_failed()
	elif game03_result == 1:
		game03_result = -1
		on_game03_successed()

# 游戏失败后调用
func on_game03_failed():
	# 播放两个视频
	skeleton_video.play()
	seisomgraph_video.play()
	# 在玩家周围实例化骷髅怪
	var player = PlayerManager.player

# 游戏成功后调用
func on_game03_successed():
	# 播放 BellPlayer 视频
	bell_player.play()
	await bell_player.finished
	# 播放石门动画（只播放一次）
	if not stone_door_opened:
		var animation_player = stone_door.get_node("AnimationPlayer")
		animation_player.play("Open")
		stone_door_opened = true

func _free_level() -> void:
	PlayerManager.unparent_player(self)
	queue_free()

func _pause_level() -> void:
	pass
	
func spawn_skeleton_monster():
	var player = PlayerManager.player  # 每次都实时获取
	print("尝试实例化骷髅怪")
	if skeleton_monster_scene:
		var monster = skeleton_monster_scene.instantiate()
		if is_instance_valid(player):
			var random_offset = Vector2(randf_range(-100, 100), randf_range(-100, 100))
			monster.position = player.global_position + random_offset
			get_tree().current_scene.add_child(monster)
			print("骷髅怪已实例化，位置：", monster.position)
		else:
			print("Player无效")
	else:
		print("skeleton_monster_scene 加载失败")
