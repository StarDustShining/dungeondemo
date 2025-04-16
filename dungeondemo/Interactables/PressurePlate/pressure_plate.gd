# PressurePlate.gd
class_name PressurePlate extends Node2D

@export var skeleton_monster_scene :PackedScene
@export var spawn_range :float = 300.0
@onready var animated_sprite = $AnimatedSprite2D
@export var monster_lifetime :float = 120
@export var fade_time :float = 1.0  # 渐变透明的时间

@onready var area = $Area2D
@onready var player:Player = PlayerManager.player

var is_depress_playing = false
var spawned_monsters = []

func _ready():
	# 连接 Area2D 的 body_entered 和 body_exited 信号
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	# 连接 AnimatedSprite2D 的 animation_finished 信号
	animated_sprite.animation_finished.connect(_on_animation_finished)

func _on_body_entered(body):
	if body == player:
		animated_sprite.animation = "depress"
		is_depress_playing = true
		spawn_skeleton_monster()

func _on_body_exited(body):
	if body == player:
		if is_depress_playing:
			# 如果 depress 动画正在播放，等待其播放完毕
			pass
		else:
			animated_sprite.animation = "upspring"

func _on_animation_finished():
	if animated_sprite.animation == "depress":
		animated_sprite.animation = "upspring"
		is_depress_playing = false
		# 确保 monster 不再继续消失
	elif animated_sprite.animation == "upspring":
		animated_sprite.animation = "idle"

func spawn_skeleton_monster():
	var monster = skeleton_monster_scene.instantiate()
	monster.scale = Vector2(1, 1)
	var random_offset = Vector2(randi_range(-int(spawn_range), int(spawn_range)), randi_range(-int(spawn_range), int(spawn_range)))
	monster.position = player.global_position + random_offset
	add_child(monster)
	spawned_monsters.append(monster)

	# 设置定时器控制怪物生命周期
	var timer = Timer.new()
	timer.wait_time = monster_lifetime
	timer.one_shot = true
	timer.timeout.connect(monster._on_timeout)
	add_child(timer)
	timer.start()

	# 为怪物设置渐变透明的参数
	monster.fade_speed = 1 / fade_time  # 设置渐变速度，使透明度在 fade_time 秒内逐渐消失

func _process(_delta):
	# 控制怪物渐变消失
	for monster in spawned_monsters:
		if is_instance_valid(monster) and monster is SkeletonMonster and monster.is_visible():
			monster.fade_out(_delta)
		else:
			# 如果怪物已经被销毁，则从列表中移除
			spawned_monsters.erase(monster)
