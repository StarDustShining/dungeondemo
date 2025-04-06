extends CanvasLayer

@onready var item_description: Label = $Control/ItemDescription
@onready var audio_stream_player: AudioStreamPlayer = $Control/AudioStreamPlayer


func update_item_description(new_text: String) -> void:
	item_description.text = new_text 


func play_audio( audio : AudioStream ) -> void:
	audio_stream_player.stream = audio
	audio_stream_player.play()
