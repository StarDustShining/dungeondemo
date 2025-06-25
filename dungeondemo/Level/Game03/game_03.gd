extends Node2D

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var letters = {
	1: $Letters/M,
	2: $Letters/N,
	3: $Letters/B,
	4: $Letters/V,
	5: $Letters/C,
	6: $Letters/X
}
var beatmap = []
var beatmap_index = 0
var fall_time = 1.40227272727275

func _ready():
	# 加载节奏点
	var file = FileAccess.open("res://Level/Game03/data/beatmap.json", FileAccess.READ)
	beatmap = JSON.parse_string(file.get_as_text())
	beatmap_index = 0
	await get_tree().create_timer(3.0).timeout  # 等待3秒
	audio_stream_player_2d.play()

func _process(delta):
	if beatmap_index >= beatmap.size():
		return
	var music_time = audio_stream_player_2d.get_playback_position()
	while beatmap_index < beatmap.size() and beatmap[beatmap_index]["time"] - fall_time <= music_time:
		var note = beatmap[beatmap_index]
		var num = int(note["num"])
		if letters.has(num):
			letters[num].CreateFallingKey()
		beatmap_index += 1
