class_name PressurePlate extends Node2D

@export var spawn_range :float = 100.0
@onready var animated_sprite = $AnimatedSprite2D
@onready var area = $Area2D
@onready var player:Player = PlayerManager.player
@onready var skeleton_video_player: VideoStreamPlayer = $CanvasLayer/SkeletonVideoPlayer
@onready var seisomgraph_video_player: VideoStreamPlayer = $CanvasLayer/SeisomgraphVideoPlayer



var is_player_in_area = false
var spawned_monsters = []
var skeleton_monster_scene:PackedScene=preload("res://Enemy/骷髅/skeletonMonster.tscn")

func _ready():
	# 确保 Area2D 的信号已正确连接
	area.area_entered.connect(_on_area_entered)
	area.area_exited.connect(_on_area_exited)
	animated_sprite.animation_finished.connect(_on_animation_finished)
	

func _on_area_entered(area: Area2D) -> void:
	animated_sprite.play("depress")
	is_player_in_area = true
	seisomgraph_video_player.play()
	skeleton_video_player.play()

func _on_area_exited(area: Area2D) -> void:
	is_player_in_area = false
	animated_sprite.play("upspring")

func _on_animation_finished():
	# 处理动画播放完后的状态切换
	if animated_sprite.animation == "depress":
		# 动画播放完后，如果玩家仍在区域内，保持最后一帧
		if not is_player_in_area:
			animated_sprite.play("upspring")
	elif animated_sprite.animation == "upspring":
		# 播放完 upspring 后，恢复为 idle 状态
		animated_sprite.play("idle")

func spawn_skeleton_monster():
	if skeleton_monster_scene:
		var monster = skeleton_monster_scene.instantiate()
		var random_offset = Vector2(randf_range(-spawn_range, spawn_range), randf_range(-spawn_range, spawn_range))
		monster.position = self.global_position + random_offset
		# 将怪物添加到主场景
		get_tree().current_scene.add_child(monster)
		spawned_monsters.append(monster)  # 存储生成的怪物
		
