extends CharacterBody2D

var race := "human"

var gravity_rate = 0.7

const MAX_SPEED = 350
const ACCELERATION_RATE = .2

# rate of gravity once the player reaches apogee of jump
const POST_FALL_GRAVITY_RATE = 1.8;
const JUMP_SPEED = 350

const TERMINAL_VELOCITY = 500
const AIR_MAX_SPEED = 220
const AIR_ACCELERATION_RATE = .15

const IDLE_THRESHOLD = 40
const LAND_STUN_TIME = 0.05
const LAND_STUN_DECCELERATION = 0.3 

const SWORD_PROJECTILE_ORIGIN = Vector2(21,-9)
const BOW_PROJECTILE_ORIGIN = Vector2(20,3)

enum STATES {
	idle,
	run,
	fall,
	wall_fall,
	wall_jump,
	jump,
	land,
	swing_floor,
	swing_air,
	dashing,
	climbing_chain,
}

var on_chain := false
var is_swinging := false
var has_landed := true
var update_anim := false

var selected_item = null

var time_until_last_grounded := 0.0
var dash_time := 0.0
var can_dash := true

var dir := 1: set = change_dir

var dash_dir: Vector2

var velocity := Vector2()

@onready var inventory = $CanvasLayer/UI/Inventory
@onready var sword_hand = $Sprites/Torso/ArmL/Forearm/Hand
@onready var intent_hand = $Sprites/Torso/ArmR/Forearm/Hand

@onready var hp_bar = $CanvasLayer/UI/HPBar/HPProgress
@onready var hp_bar_lag = $CanvasLayer/UI/HPBar/HPProgressUnder

@onready var dialogue_node = $CanvasLayer/UI/Dialogue
@onready var dialogue_color = \
	$CanvasLayer/UI/Dialogue/VBoxContainer/HBoxContainer/ColorRect
@onready var dialogue_tween = \
	$CanvasLayer/UI/Dialogue/VBoxContainer/HBoxContainer/ColorRect/Tween
@onready var dialogue_label = \
	$CanvasLayer/UI/Dialogue/VBoxContainer/HBoxContainer/ColorRect/Label

signal next_dialogue()
signal break_block_start(block)
signal break_block_end(block)

var state := 0

var _input_strength := 1.0
var _input_strength_gain := 0.04 # input strength gains this each frame

@onready var _init_camera_offset: Vector2 = $Camera3D.offset

var cape_points := [
	# offset  , max_dist , pos   , radius
	[Vector2(0,0),      0, Vector2(0, 0), 5],
	[Vector2(0,1),      3, Vector2(0, 0), 5],
	[Vector2(0,2),    3, Vector2(0, 0), 4.5],
	[Vector2(0,3),      4, Vector2(0, 0), 4],
	[Vector2(0,4),    4, Vector2(0, 0), 3.5],
	[Vector2(-0.2,4.3), 5, Vector2(0, 0), 3],
]
var show_points := false

var max_stamina = 100
var stamina = max_stamina: set = set_stamina

func _ready():
	
	pass
	#$Camera.position = (OS.window_size/-2)*$Camera.zoom
	#$Camera.offset = Vector2()
	

func _draw():
	pass
#	for point in cape_points:
#		draw_circle(point[2]-position, point[3], Color(0.988281, 0.941835, 0.563629))

func _physics_process(delta):
	
	set_stamina(stamina + 0.4)
	
	if Engine.is_editor_hint():
		return
	
	$Camera3D.offset = _init_camera_offset + ($Camera3D.offset-_init_camera_offset).lerp(get_local_mouse_position()*0.175, 0.02)
	
	if Input.is_action_just_pressed("ui_down"):
		set_collision_mask_value(4, false)
		await get_tree().create_timer(0.2).timeout
		set_collision_mask_value(4, true)
	
	# inspired from https://www.youtube.com/watch?v=LpYvjVmjfRw
	for i in range(cape_points.size()-1, -1, -1):
		if i == 0:
			cape_points[i][2] = $Sprites/Torso/Helm.global_position + Vector2(-0.5, 12)
			continue
		# average pos is between its neighbors
		cape_points[i][2] = (cape_points[i][0]+cape_points[i][2]+cape_points[i-1][2])/2
	
	for i in range(cape_points.size()):
		if i == 0: continue
		
		if cape_points[i][2].distance_to(cape_points[i][0]+cape_points[i-1][2]) > cape_points[i][1]:
			var dir = (cape_points[i-1][2]+cape_points[i][0]).direction_to(cape_points[i][2])
			var offset = dir * cape_points[i][1]
			cape_points[i][2] = cape_points[i-1][2]+offset+cape_points[i][0]
	
	var input = Vector2((Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")), \
					(Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")))
	input *= _input_strength
	_input_strength += _input_strength_gain
	_input_strength = clamp(_input_strength, 0, 1)
	
	var dir_changed = false
	if not input.x == 0 and not is_swinging:
		dir_changed = (dir == int(input.x / abs(input.x)))
		change_dir(int(input.x / abs(input.x)))
	
	var new_state := 0
	
	time_until_last_grounded += delta
	if is_on_floor():
		time_until_last_grounded = 0.0
		
		if dir_changed:
			velocity.x = dir * abs(velocity.x)
		if has_landed:
			can_dash = true
			new_state = STATES.run if abs(velocity.x) >= IDLE_THRESHOLD else STATES.idle
			
		else:
			new_state = STATES.land
	else:
		has_landed = false
		new_state = STATES.fall
		
		if is_on_wall():
			new_state = STATES.wall_fall
	
	if input.y < 0 and on_chain:
		new_state = STATES.climbing_chain
	
	if Input.is_action_just_pressed("ui_up"):
		if is_on_floor_approx():
			new_state = STATES.jump
		elif state == STATES.wall_fall:
			new_state = STATES.wall_jump
	
	
	#Animation transition states
	if new_state != state or update_anim:
		var anim = [null, null]
		match(new_state):
			STATES.run:
				anim = ["Run", "Run"]
						
			STATES.idle:
				anim = ["Idle", "Idle"]
						
			STATES.fall, STATES.wall_fall:
				anim = ["Fall", "Fall"]
						
			STATES.jump:
				anim = ["Jump", "Jump"]
						
			STATES.land:
				anim = ["Land", "Land"]
				$LandedTimer.start(LAND_STUN_TIME)
						
			STATES.swing_floor:
				is_swinging = true
				anim = ["Swing", null]
						
			STATES.swing_air:
				is_swinging = true
				anim = ["Swing", null]
						
			STATES.dashing:
#				$DashTween.interpolate_property($CanvasLayer/ColorRect.material, "shader_param/brightness", 1.2, 1, 0.4, Tween.TRANS_QUAD,Tween.EASE_IN)
#				velocity = Vector2()
#				dash_dir = get_local_mouse_position().normalized()
#				dash_time = 0
#				can_dash = false
#				
#				yield(get_tree(), "idle_frame")
#				$DashTween.start()
				
				
				$TopAnim.stop()
				$BotAnim.stop()
				$DashTween.interpolate_property($CanvasLayer/ColorRect.material, "shader_param/brightness", 1.2, 1, 0.4, Tween.TRANS_QUAD,Tween.EASE_IN)
				$DashTween.interpolate_property(self, "stamina", stamina, stamina-40, 0.4, Tween.TRANS_QUAD, Tween.EASE_IN)
				velocity.y = -150
				if get_local_mouse_position().x != 0:
					dash_dir = Vector2(sign(get_local_mouse_position().x), 0)
				dash_time = 0
				can_dash = false
				change_dir(dash_dir)
				$Roll.play("Dive")
				update_anim = false
				await get_tree().idle_frame
				$DashTween.start()
				is_swinging = false
				
		play_animation(anim)
	
	state = new_state
	
	#Physics in each state
	var top_playback_speed = $TopAnim.playback_speed
	var bot_playback_speed = $BotAnim.playback_speed
	
	$DustParticles.emitting = false
	$DustParticles2.emitting = false
	
	match(state):
		STATES.run:
			$DustParticles.emitting = true
			$DustParticles2.emitting = true
			velocity.y = 5
			velocity.x = lerp(velocity.x, input.x * MAX_SPEED, ACCELERATION_RATE)
			if !is_swinging:
				top_playback_speed = (abs(velocity.x) / MAX_SPEED) * 0.2 + 0.8
			bot_playback_speed = (abs(velocity.x) / MAX_SPEED) * 0.2 + 0.8
		STATES.idle:
			velocity.y = 5
			velocity.x = lerp(velocity.x, input.x * MAX_SPEED, ACCELERATION_RATE)
		STATES.fall, STATES.wall_fall:
			velocity.y += 20 * gravity_rate * \
			(POST_FALL_GRAVITY_RATE if (velocity.y > 0 or not Input.is_action_pressed("ui_up")) else 1)
			if is_on_ceiling(): velocity.y = 1
			velocity.x = lerp(velocity.x, input.x * AIR_MAX_SPEED, AIR_ACCELERATION_RATE)
			velocity.y = clamp(velocity.y, -TERMINAL_VELOCITY, TERMINAL_VELOCITY)
		STATES.jump:
			velocity.y = -JUMP_SPEED
			velocity.x = lerp(velocity.x, input.x * AIR_MAX_SPEED, AIR_ACCELERATION_RATE)
		STATES.wall_jump:
			velocity.y = -JUMP_SPEED * 0.9
			velocity.x = (-1 if $RayCast2D.is_colliding() else 1)*JUMP_SPEED * 1.3
			_input_strength = 0.0
		STATES.land:
			velocity.y = 5
			var temp_dir = velocity.x/abs(velocity.x) if velocity.x != 0 else float(dir)
			velocity.x = lerp(velocity.x, temp_dir, LAND_STUN_DECCELERATION)
		STATES.swing_floor:
			velocity.y = 5
			velocity.x = lerp(velocity.x, input.x * MAX_SPEED, ACCELERATION_RATE)
		STATES.swing_air:
			velocity.y += 20 * gravity_rate * \
			(POST_FALL_GRAVITY_RATE if (velocity.y > 0 or not Input.is_action_pressed("ui_jump")) else 1)
			if is_on_ceiling(): velocity.y = 1
			velocity.x = lerp(velocity.x, input.x * AIR_MAX_SPEED, AIR_ACCELERATION_RATE)
#		STATES.dashing:
#			for dashcast in $DashCasts.get_children():
#				dashcast.cast_to = velocity / 60
#				dashcast.force_raycast_update()
#				if dashcast.is_colliding() and dashcast.get_collider().is_in_group("Monster"):
#					var mon = dashcast.get_collider()
#					if not mon is BaseMonster:
#						continue
#					mon.take_damage(10, KnockbackInformation.new(position-velocity*2, 4))
#					dash_dir = dash_dir.bounce(dashcast.get_collision_normal())
#					$DashTween.interpolate_property(Engine, "time_scale", 0.3, 1, 0.4, Tween.TRANS_EXPO,Tween.EASE_IN)
#					can_dash = true
#					break
#
#			velocity = dash_dir * 1000 * log(-370*pow(dash_time, 6)+7)/(log(2.71828))*0.51
#			dash_time += delta
#
#			if dash_time > 0.15:
#				velocity = velocity.normalized() * MAX_SPEED
#				state = 0
#				dash_time = 0
		STATES.dashing:
#			for dashcast in $DashCasts.get_children():
#				dashcast.cast_to = velocity / 60
#				dashcast.force_raycast_update()
#				if dashcast.is_colliding() and dashcast.get_collider().is_in_group("Monster"):
#					var mon = dashcast.get_collider()
#					if not mon is BaseMonster:
#						continue
#					mon.take_damage(10, KnockbackInformation.new(position-velocity*2, 4))
#					#dash_dir = dash_dir.bounce(dashcast.get_collision_normal())
#					$DashTween.interpolate_property(Engine, "time_scale", 0.3, 1, 0.4, Tween.TRANS_EXPO,Tween.EASE_IN)
#					can_dash = true
#
#					break
			
			velocity.y += 20 * 0.5
			velocity.x = dash_dir.x * 100 * 1/min(0.6,max(2*dash_time,0.2))
			dash_time += delta
			
			if dash_time > 0.2:
				$Roll.play("Roll")
				$Roll.playback_speed = min(2,10*pow(dash_time, 1.7))
		STATES.climbing_chain:
			velocity.y = -25
			velocity.x = lerp(velocity.x, 0, 0.1)
	
	
	$TopAnim.playback_speed = top_playback_speed	
	$BotAnim.playback_speed = bot_playback_speed
	
	
# warning-ignore:return_value_discarded
	set_velocity(velocity)
	set_up_direction(Vector2.UP)
	set_floor_stop_on_slope_enabled(false)
	set_max_slides(4)
	set_floor_max_angle(0.78)
	# TODOConverter3To4 infinite_inertia were removed in Godot 4 - previous value `false`
	move_and_slide()
	for slide_idx in range(get_slide_collision_count()):
		var collision = get_slide_collision(slide_idx)
		if collision.collider is RigidBody2D and collision.collider.is_in_group("Pushable"):
			collision.collider.apply_central_impulse(-collision.normal * velocity.length() )
	
	if show_points:
		update()
	

func play_animation(anim_vect):
	update_anim = false
	
	if anim_vect.has("Swing"):
		match selected_item.type:
			"sword", "harvester":
				
				if selected_item.type == "harvester":
					$Sprites/Sword.add_to_group("Harvester")
				elif $Sprites/Sword.is_in_group("Harvester"):
					$Sprites/Sword.remove_from_group("Harvester")
				$TopAnim.playback_speed = (selected_item.get_class_data()["speed"]*.1)
				$TopAnim.play("SwordSwing")
				$SwingTimer.start($TopAnim.current_animation_length/(selected_item.get_class_data()["speed"]*.1) + 0.5)
				
				var sword_node = selected_item.use_node
				if sword_hand.get_child_count() > 0:
					if sword_hand.get_child(0) != sword_node:
						sword_hand.remove_child(sword_hand.get_child(0))
						sword_hand.add_child(sword_node)
				else:
					sword_hand.add_child(sword_node)
				
				var sprite_to_mouse = Vector2(
					get_local_mouse_position().x * sign($Sprites.scale.x),
					get_local_mouse_position().y
				)
				$Sprites/Sword.rotation = clamp(
					sprite_to_mouse.angle()
				, -PI/6, PI/6)
				
				selected_item.use(get_angle_to(get_global_mouse_position()),to_global( \
					SWORD_PROJECTILE_ORIGIN * $Sprites.scale))
				
				#selected_item.get_class_data()["speed"]
			
			"praecis":
				pass
			
			"intent":
				$TopAnim.playback_speed = (selected_item.get_class_data()["speed"]*.1)
				$TopAnim.play("IntentSwing")
				$SwingTimer.start($TopAnim.current_animation_length/(selected_item.get_class_data()["speed"]*.1) + 0.5)
				
				var intent_node = selected_item.use_node
				if intent_hand.get_child_count() > 0:
					if intent_hand.get_child(0) != intent_node:
						intent_hand.remove_child(intent_hand.get_child(0))
						intent_hand.add_child(intent_node)
				else:
					intent_hand.add_child(intent_node)
					
				intent_node.position = Vector2(3.842, -1.175)
				selected_item.use($CanvasLayer/UI/Inventory.equiped_praecis(), get_angle_to(get_global_mouse_position()))
			
			"bow":
				$TopAnim.playback_speed = 1
				$TopAnim.play("BowSwing")
				$SwingTimer.start($TopAnim.current_animation_length/(selected_item.get_class_data()["speed"]*.1) + 0.5)
				
				var bow_node = selected_item.use_node
				if sword_hand.get_child_count() > 0:
					if sword_hand.get_child(0) != bow_node:
						sword_hand.remove_child(sword_hand.get_child(0))
						sword_hand.add_child(bow_node)
				else:
					sword_hand.add_child(bow_node)
					
				selected_item.use()

	else:
		if anim_vect[0] != null and !is_swinging:
			$TopAnim.play(anim_vect[0])

		if anim_vect[1] != null:
			$BotAnim.play(anim_vect[1])

func change_dir(val):
	if val is Vector2:
		val = val.x
	dir = val
	$Sprites.scale.x = val

func is_on_floor_approx():
	return time_until_last_grounded < 0.2


func set_stamina(val: float):
	stamina = clamp(val, 0, 100)
	pass

func add_knockback(vec: Vector2):
	velocity = Vector2(-sign(vec.x), -0.7) * vec.length()

func create_blood(kb_info):
	pass

func LandedTimer_timeout():
	has_landed = true


func SwingTimer_timeout():
	is_swinging = false
	update_anim = true

func Inventory_selected_changed():
	if inventory == null:
		return
	if selected_item != inventory.get_selected():
		_remove_children(intent_hand)
		_remove_children(sword_hand)
	selected_item = inventory.get_selected()
	
	

func _remove_children(node):
	if node.get_child_count() > 0:
		for i in node.get_children():
			node.remove_child(i)

func is_click_on_inventory():
	if inventory.get_node("Bag").visible:
		if $Camera3D.get_local_mouse_position().x / $Camera3D.zoom.x > 348:
			return false
		else:
			return true
	else:
		return false

func use_sword():
	
	if selected_item:
		if selected_item.has_method("shoot"):
			selected_item.shoot(get_angle_to(get_global_mouse_position()),to_global( \
					SWORD_PROJECTILE_ORIGIN * $Sprites.scale))
		
	
func swing_finished():
	$SwingTimer.stop()
	is_swinging = false
	update_anim = true

# when sword reaches top of player
func swing_apex():
	#velocity.x += 500 * $Sprites.scale.x
	pass

func use_bow():
	selected_item.shoot(get_angle_to(get_global_mouse_position()),to_global( \
					BOW_PROJECTILE_ORIGIN * $Sprites.scale))
	pass

func _on_Roll_animation_finished(anim_name):
	if anim_name == "Roll":
		$Roll.play("RESET")
		$Roll.playback_speed = 1
		dash_time = 0
		state = 0

func sword_body_entered(body):
	if body.is_in_group("Monster"):
		await get_tree().idle_frame
		velocity.x += 200*sign(to_local(body.global_position).x)

func say(text: String):
	if text == "": 
		$CanvasLayer/UI/Dialogue.hide()
		return
	$CanvasLayer/UI/Dialogue.show()
	
	# if player exited NPC before talking to him
	if dialogue_label.text == "":
		$CanvasLayer/UI/Dialogue/AnimationPlayer.play_backwards("Shrink")
	
	dialogue_label.text = text
	dialogue_tween.interpolate_property(\
		dialogue_label, "percent_visible",0,1,text.length()/40,Tween.TRANS_LINEAR)
	dialogue_tween.start()
func unsay():
	$CanvasLayer/UI/Dialogue/AnimationPlayer.play("Shrink")
	dialogue_label.text = ""


func _on_Dialogue_gui_input(event: InputEvent):
	if event is InputEventMouseButton and dialogue_color.modulate.a > 0.9:
		if event.is_pressed():
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					emit_signal("next_dialogue")


