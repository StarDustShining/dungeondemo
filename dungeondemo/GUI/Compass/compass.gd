class_name Compass extends Control

# 磁石的位置
var magnet_position = Vector2(0, 0)
# 磁石的作用半径
var magnet_radius = 100

@onready var spoon: Sprite2D = $spoon


func _ready():
	# 加入一个组以便接收信号
	add_to_group("compass_group")

func _process(delta):
	var player_position = get_player_position()  # 你需要实现这个函数来获取玩家的位置
	var distance_to_magnet = player_position.distance_to(magnet_position)
	
	if distance_to_magnet <= magnet_radius:
		# 显示司南
		visible = true
		# 计算磁勺的方向
		var direction = magnet_position - player_position
		var angle = direction.angle()
		# 更新磁勺的角度
		spoon.rotation = angle
	else:
		# 隐藏司南
		visible = false

func get_player_position():
	return PlayerManager.player.global_position

func player_entered_magnet_area(new_position):
	magnet_position = new_position
	

func player_exited_magnet_area():
	pass
	
