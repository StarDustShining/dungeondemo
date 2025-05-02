extends CanvasLayer

@onready var item_description: Label = $Control/ItemDescription
@onready var audio_stream_player: AudioStreamPlayer = $Control/AudioStreamPlayer


var description_timer : Timer ###
func update_item_description(new_text: String) -> void:
	item_description.text = new_text
	
	###
	if description_timer:
		description_timer.stop()

	description_timer = Timer.new()
	add_child(description_timer)
	description_timer.wait_time = 5 #物品描述5秒消失
	description_timer.one_shot = true
	description_timer.timeout.connect( func():
		item_description.text = ""
		description_timer.queue_free()
	)
	description_timer.start()


func play_audio( audio : AudioStream ) -> void:
	if audio == null:
		return
	audio_stream_player.stream = audio
	audio_stream_player.play()
	

###
func get_all_slots() -> Array:
	return $Control/PanelContainer/GridContainer.get_children()
