@tool
class_name Chime extends Node

var is_open: bool = false
var game_path: String = "res://Level/Game03/game03.tscn"
var minigame_instance: Node = null  # 用于存储加载的小游戏实例

@onready var interact_area: Area2D = $E

func _ready() -> void:
	interact_area.area_entered.connect(OnAreaEnter)
	interact_area.area_exited.connect(OnAreaExit)

func player_interact() -> void:
	# 切换到小游戏场景
	# 使用 await 调用协程，并获取返回值
	minigame_instance = await LevelManager.load_minigame(game_path)

func OnAreaEnter(_a: Area2D) -> void:
	PlayerManager.interact_pressed.connect(player_interact)

func OnAreaExit(_a: Area2D) -> void:
	PlayerManager.interact_pressed.disconnect(player_interact)
