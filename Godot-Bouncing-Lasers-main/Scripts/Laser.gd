extends Node2D

var sender

var bounces := 3

var rot := 0.0

const MAX_LENGTH := 2000 # max length 

@onready var line = $Line2D
var max_cast_to # vector that updates based on rotation

var lasers := []

func _ready():
	
	sender = get_parent()
	
	lasers.append($Laser)
	for i in range(bounces):
		var raycast = $Laser.duplicate()
		raycast.enabled = false
		raycast.add_exception(sender)
		add_child(raycast)
		lasers.append(raycast)
	
	max_cast_to = Vector2(MAX_LENGTH, 0).rotated(rot)
	$Laser.add_exception(sender)
	$Laser.target_position = max_cast_to
	$Line2D.set_as_top_level(true)
	

func _process(_delta):
	
	$End.emitting = true
	rot = get_local_mouse_position().angle()
	
	line.clear_points()
	line.add_point(global_position)
	
	max_cast_to = Vector2(MAX_LENGTH, 0).rotated(rot)
	
	var idx = -1
	for raycast in lasers:
		
		idx += 1
		var raycastcollision = raycast.get_collision_point()
		
		raycast.target_position = max_cast_to
		if raycast.is_colliding():
			line.add_point(raycastcollision)
			
			max_cast_to = max_cast_to.bounce(raycast.get_collision_normal())
			if idx < lasers.size()-1:
				lasers[idx+1].enabled = true
				lasers[idx+1].global_position = raycastcollision+(1*max_cast_to.normalized())
			if idx == lasers.size()-1:
				$End.global_position = raycastcollision
		else:
			line.add_point(global_position + max_cast_to)
			$End.emitting = false
			break
			
		

