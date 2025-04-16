extends CharacterBody2D

@export var walk_speed = 200 # 走路速度
@export var run_speed = 250 # 跑步速度
@export var tile_size : float = 32 # 瓦片大小
@export var max_hp = 6 # 最大生命值
@export var footstep_sound_interval = 0.3 # 脚步声间隔时间

@onready var animation_player = $AnimationPlayer # 动画播放器节点引用
@onready var sprite = $Graphic/Sprite2D # 精灵节点引用

# 添加音频播放器引用，如果没有则需要创建
@onready var audio_player = $AudioStreamPlayer2D if has_node("AudioStreamPlayer2D") else null

var direction = Vector2.ZERO
var bounds : Array[Vector2] = []
var hp = 6 # 当前生命值
var invulnerable = false # 无敌状态
var invulnerable_timer = 0.0 # 无敌时间计时器
var hurt_flash_timer = 0.0 # 受伤闪烁计时器
var hurt_flash_duration = 0.1 # 闪烁持续时间
var flash_count = 0 # 闪烁次数
var footstep_timer = 0.0 # 脚步声计时器

# 预加载音效资源
var footstep_sound = preload("res://Player/walk.mp3") if ResourceLoader.exists("res://Player/walk.mp3") else null
var hurt_sound = preload("res://Player/倒地.mp3") if ResourceLoader.exists("res://Player/倒地.mp3") else null
var run_sound = preload("res://Player/run.mp3") if ResourceLoader.exists("res://Player/run.mp3") else null
var death_sound = preload("res://Player/death.mp3") if ResourceLoader.exists("res://Player/death.mp3") else null

func _ready():
	# 连接信号
	LevelManager.tilemap_bounds_changed.connect(_on_bounds_changed)
	LevelManager.level_load_started.connect(_save_health_to_global)
	
	# 从全局 PlayerManager 获取血量（如果有）
	var global_player = get_node_or_null("/root/PlayerManager").player if has_node("/root/PlayerManager") else null
	if global_player and global_player.hp != null and global_player.max_hp != null:
		# 继承全局玩家的血量
		hp = global_player.hp
		max_hp = global_player.max_hp
		print("从全局玩家继承血量: ", hp, "/", max_hp)
	else:
		hp = max_hp
		print("使用默认血量: ", hp, "/", max_hp)
	
	# 创建音频播放器（如果不存在）
	if not audio_player:
		audio_player = AudioStreamPlayer2D.new()
		add_child(audio_player)
		audio_player.max_distance = 2000
		audio_player.volume_db = -10
	
	# 处理PlayerManager.interact信号
	PlayerManager.interact_pressed.connect(_on_interact)
	
	# 如果全局玩家为空，我们可以添加一些特殊处理
	if not PlayerManager.player_spawned or not PlayerManager.player:
		print("全局玩家不存在，当前downplayer将处理所有玩家相关逻辑")
	
	print("当前场景使用 downplayer 作为主要玩家")

func _on_bounds_changed(new_bounds : Array[Vector2]):
	bounds = new_bounds

func calculate_tilemap_bounds(tilemap: TileMap) -> void:
	bounds = []
	bounds.append(Vector2(tilemap.get_used_rect().position * tile_size) + tilemap.position)
	bounds.append(Vector2(tilemap.get_used_rect().end * tile_size) + tilemap.position)

func _process(delta):
	# 获取输入方向
	direction.x = Input.get_action_strength("右") - Input.get_action_strength("左")
	direction.y = Input.get_action_strength("下") - Input.get_action_strength("上")
	
	# 归一化方向向量，确保斜向移动速度不会更快
	if direction.length() > 1:
		direction = direction.normalized()
		
	# 处理受伤闪烁效果
	if hurt_flash_timer > 0:
		hurt_flash_timer -= delta
		if hurt_flash_timer <= 0:
			flash_count -= 1
			if flash_count > 0:
				# 继续闪烁
				hurt_flash_timer = hurt_flash_duration
				toggle_flash()
			else:
				# 停止闪烁
				sprite.modulate = Color(1, 1, 1, 0.5 if invulnerable else 1.0)
	
	# 处理脚步声
	if direction.length() > 0:
		footstep_timer -= delta
		if footstep_timer <= 0:
			play_footstep_sound()
			footstep_timer = footstep_sound_interval

func _physics_process(delta):
	# 处理无敌时间
	if invulnerable:
		invulnerable_timer -= delta
		if invulnerable_timer <= 0:
			invulnerable = false
			if hurt_flash_timer <= 0:  # 如果闪烁已经结束
				sprite.modulate = Color(1, 1, 1, 1.0)  # 恢复正常颜色和不透明度
	
	# 根据是否按下 shift 键决定速度
	var current_speed = run_speed if Input.is_action_pressed("shift") else walk_speed
	
	# 根据移动方向播放对应动画
	if direction.length() > 0:
		if abs(direction.x) > abs(direction.y):
			# 水平移动
			if direction.x > 0:
				animation_player.play("walk_right")
			else:
				animation_player.play("walk_left")
		else:
			# 垂直移动
			if direction.y > 0:
				animation_player.play("walk_down")
			else:
				animation_player.play("walk_up")
	else:
		# 如果没有移动，停止动画
		animation_player.stop()
	
	# 设置速度并移动
	velocity = direction * current_speed
	
	# 检查移动后的位置是否在边界内
	var next_position = global_position + velocity * delta
	if bounds.size() == 2:
		next_position.x = clamp(next_position.x, bounds[0].x, bounds[1].x)
		next_position.y = clamp(next_position.y, bounds[0].y, bounds[1].y)
		velocity = (next_position - global_position) / delta
	
	move_and_slide()
	
	# 处理交互
	if Input.is_action_just_pressed("交互"):
		# 直接触发交互信号，不通过PlayerManager
		PlayerManager.interact_pressed.emit()

# 播放脚步声
func play_footstep_sound():
	if not audio_player:
		return
		
	# 根据玩家是否在跑步选择不同音效
	var is_running = Input.is_action_pressed("shift")
	var sound = run_sound if is_running else footstep_sound
	
	if sound:
		audio_player.stream = sound
		audio_player.pitch_scale = randf_range(0.9, 1.1)  # 随机音调变化
		audio_player.play()

# 播放受伤声音
func play_hurt_sound():
	if audio_player and hurt_sound:
		audio_player.stream = hurt_sound
		audio_player.pitch_scale = 1.0
		audio_player.play()

# 更新生命值，正数增加，负数减少
func UpdateHp(value: int) -> void:
	if invulnerable:
		return
		
	hp = clamp(hp + value, 0, max_hp)
	
	if value < 0:  # 受到伤害
		invulnerable = true
		invulnerable_timer = 1.0  # 1秒无敌时间
		
		# 播放受伤音效
		if hurt_sound and audio_player:
			audio_player.stream = hurt_sound
			audio_player.play()
			
		# 开始受伤闪烁效果
		start_hurt_effect()
		
		# 检查死亡
		if hp <= 0:
			Die()
			return
	
	# 更新UI显示
	if get_node_or_null("/root/PlayerHud"):
		get_node("/root/PlayerHud").UpdateHp(hp, max_hp)
	
	# 通知 PlayerManager 更新血量
	var player_manager = get_node_or_null("/root/PlayerManager")
	if player_manager and player_manager.has_method("set_health"):
		player_manager.set_health(hp, max_hp)

# 设置无敌状态
func MakeInvulnerable(duration: float) -> void:
	invulnerable = true
	invulnerable_timer = duration

# 处理死亡
func Die() -> void:
	print("玩家死亡")
	
	# 停止移动
	velocity = Vector2.ZERO
	
	# 播放死亡动画
	animation_player.play("diedie")
	
	# 播放死亡音效
	if audio_player and death_sound:
		audio_player.stream = death_sound
		audio_player.pitch_scale = 1.0
		audio_player.play()
	
	# 等待动画完成
	if animation_player.has_animation("diedie"):
		await animation_player.animation_finished
	else:
		# 如果没有动画，等待一小段时间
		await get_tree().create_timer(1.0).timeout
	
	# 本地处理死亡，不调用全局玩家的死亡方法
	# 重置血量
	hp = max_hp
	
	# 重置玩家状态
	sprite.modulate = Color(1, 1, 1, 1.0)
	
	# 更新UI
	if get_node_or_null("/root/PlayerHud"):
		get_node("/root/PlayerHud").UpdateHp(hp, max_hp)

# 开始受伤特效
func start_hurt_effect() -> void:
	# 设置闪烁次数和初始计时器
	flash_count = 5  # 闪烁5次
	hurt_flash_timer = hurt_flash_duration
	# 开始第一次闪烁
	toggle_flash()
	
# 切换闪烁状态
func toggle_flash() -> void:
	if sprite.modulate.r == 1.0:  # 如果是正常颜色
		sprite.modulate = Color(1, 0, 0, 0.8)  # 变成红色
	else:  # 如果是红色
		sprite.modulate = Color(1, 1, 1, 0.5)  # 变回正常颜色（半透明）

# 处理交互事件
func _on_interact() -> void:
	print("Downplayer 处理交互事件")
	# 在这里添加交互逻辑
	PlayerManager.interact_handled = true

# 处理交互按钮按下
func _input(event):
	if event.is_action_pressed("交互"):
		# 不需要调用PlayerManager.interact()，因为会在_physics_process中处理
		pass

# 在场景切换前保存血量到全局管理器
func _save_health_to_global():
	var player_manager = get_node_or_null("/root/PlayerManager")
	if player_manager and player_manager.player:
		player_manager.player.hp = hp
		player_manager.player.max_hp = max_hp
		print("保存血量到全局玩家: ", hp, "/", max_hp)
	else:
		# 如果没有全局玩家，直接使用 PlayerManager 的 set_health 函数
		if player_manager and player_manager.has_method("set_health"):
			player_manager.set_health(hp, max_hp)
			print("通过 set_health 保存血量: ", hp, "/", max_hp)
