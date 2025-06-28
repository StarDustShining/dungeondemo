extends Node2D

signal minigame_finished(result)

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var letters = {
	1: $Letters/M,
	2: $Letters/N,
	3: $Letters/B,
	4: $Letters/V,
	5: $Letters/C,
	6: $Letters/X
}
@onready var orbits = {
	6: $Orbit/OrbitX,
	5: $Orbit/OrbitC,
	4: $Orbit/OrbitV,
	3: $Orbit/OrbitB,
	2: $Orbit/OrbitN,
	1: $Orbit/OrbitM
}
var beatmap = []
var beatmap_index = 0
var fall_time = 1.40227272727275
var game_started := false
var min_score = 10000

var key_map = {
	"button_M": 1,
	"button_N": 2,
	"button_B": 3,
	"button_V": 4,
	"button_C": 5,
	"button_X": 6
}

@onready var player:Player=PlayerManager.player

func _ready():
	$Camera2D.enabled = true
	player.get_node("Camera2D").enabled = false
	# 加载节奏点
	var file = FileAccess.open("res://Level/Game03/data/beatmap.json", FileAccess.READ)
	beatmap = JSON.parse_string(file.get_as_text())
	beatmap_index = 0
	audio_stream_player_2d.finished.connect(_on_music_finished)
	var countdown_label = $UI/CanvasLayer/Countdown
	var failed_label = $UI/CanvasLayer/Failed
	var successed_label = $UI/CanvasLayer/Successed
	countdown_label.modulate.a = 0  # 初始设为透明
	failed_label.modulate.a = 0
	successed_label.modulate.a = 0

	# 1秒后播放倒计时动画
	await get_tree().create_timer(1.0).timeout
	var anim_player = $UI/AnimationPlayer
	countdown_label.text = "3"
	anim_player.play("countdown")
	await anim_player.animation_finished
	countdown_label.text = "2"
	anim_player.play("countdown")
	await anim_player.animation_finished
	countdown_label.text = "1"
	anim_player.play("countdown")
	await anim_player.animation_finished
	countdown_label.text = ""
	
	# 倒计时结束，开始游戏
	game_started = true
	audio_stream_player_2d.play()

func _process(delta):
	if not game_started:
		return
	if beatmap_index >= beatmap.size():
		return
	var music_time = audio_stream_player_2d.get_playback_position()
	while beatmap_index < beatmap.size() and beatmap[beatmap_index]["time"] - fall_time <= music_time:
		var note = beatmap[beatmap_index]
		var num = int(note["num"])
		if letters.has(num):
			letters[num].CreateFallingKey()
		beatmap_index += 1

	# 检查按键，播放BackLine动画
	for key in key_map.keys():
		if Input.is_action_just_pressed(key):
			var num = key_map[key]
			if orbits.has(num):
				var orbit = orbits[num]
				var anim = orbit.get_node("BackLineAnimation")
				anim.play("backline")
				anim.speed_scale = 2.0

				# 随机播放FrontLine动画
				var frontline_anim = orbit.get_node("FrontLineAnimation")
				frontline_anim.play("frontline")
				var anim_length = frontline_anim.get_animation("frontline").length
				var random_time = randf_range(0, anim_length)
				frontline_anim.seek(random_time, true)

func _on_music_finished():
	var anim_player = $UI/AnimationPlayer
	var score_ui = $UI  # 你的分数脚本挂在UI上
	var is_success = score_ui.score >= min_score
	if is_success:
		anim_player.play("Success")
	else:
		anim_player.play("Failed")
	await anim_player.animation_finished
	# 获取主关卡节点（假设主关卡是当前场景）
	var main_level = get_tree().current_scene
	main_level.game03_result = is_success if is_success else 0  # 1=成功, 0=失败
	emit_signal("minigame_finished", is_success)  # 传递结果
	player.get_node("Camera2D").enabled = true
	#get_tree().change_scene_to_file("res://Level/ChimeBellLevel/chime_level.tscn")
	queue_free()  # 直接销毁当前小游戏节点
