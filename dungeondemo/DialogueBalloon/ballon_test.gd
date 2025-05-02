extends BaseDialogueTestScene

const BALLOON = preload("res://DialogueBalloon/Balloon.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var balloon: Node = BALLOON.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(resource, title)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
