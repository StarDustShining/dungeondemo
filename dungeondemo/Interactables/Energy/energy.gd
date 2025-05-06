extends Node2D

@onready var area: Area2D = $Area2D
@onready var hint_label: Label = $HintLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var player_in_area: bool = false
var hint_showed:bool=false

func _ready():
	area.area_entered.connect(_on_Area2D_area_entered)
	area.area_exited.connect(_on_Area2D_area_exited)

# 当玩家进入区域时触发
func _on_Area2D_area_entered(_area: Area2D) -> void:
	player_in_area = true
	if !hint_showed:
		show_hint_label()

# 当玩家离开区域时触发
func _on_Area2D_area_exited(_area: Area2D) -> void:
	player_in_area = false
	
func show_hint_label() -> void:
	# 设置提示标签的文本
	hint_label.text = "此处乃地脉显象，脉息本应深藏地下，\n今因失衡而浮现，唯可借古术重归正位。"
	
	# 播放弹出动画
	animation_player.play("show_hint")
	
	# 在2秒后开始消失动画
	get_tree().create_timer(2.0).timeout.connect(_on_timer_timeout)

func _on_timer_timeout() -> void:
	# 播放消失动画
	animation_player.play("hide_hint")
