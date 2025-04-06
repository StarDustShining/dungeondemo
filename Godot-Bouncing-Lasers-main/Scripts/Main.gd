extends Node2D

func _ready():
	$ParallaxBackground/Sprite2D.texture = $SubViewport.get_texture()

func _process(delta):
	$SubViewport/Camera2D.position = $Player/Camera3D.global_position
	$SubViewport/Camera2D.offset = $Player/Camera3D.offset
