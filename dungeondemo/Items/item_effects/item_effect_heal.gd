class_name ItemEffectHeal extends ItemEffect

@export var heal_amount : int = 1
@export var audio : AudioStream


func use() -> void:
	PlayerManager.player.UpdateHp( heal_amount )
	BackpackMenu.play_audio( audio )
