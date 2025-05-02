@tool
class_name BaguaTable extends Node

@onready var interact_area: Area2D = $E
@onready var hint_label: Label = $HintLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var player:Player = PlayerManager.player
@onready var long_yin: AudioStreamPlayer2D = $LongYin
@onready var video_stream_player: VideoStreamPlayer = $CanvasLayer/VideoStreamPlayer


# 定义八卦石的资源路径
var bagua_stones = [
	"res://Items/xun.tres",
	"res://Items/qian.tres",
	"res://Items/dui.tres",
	"res://Items/li.tres",
	"res://Items/zhen.tres",
	"res://Items/kun.tres",
	"res://Items/gen.tres",
	"res://Items/kan.tres"
]

func _ready() -> void:
	interact_area.area_entered.connect(OnAreaEnter)
	interact_area.area_exited.connect(OnAreaExit)
	hint_label.visible = false
	# 连接 VideoStreamPlayer 的 finished 信号
	video_stream_player.finished.connect(_on_VideoStreamPlayer_finished)

func player_interact() -> void:
	# 检查玩家背包中是否有足够数量的八卦石
	var has_all_bagua_stones = true
	for bagua_stone in bagua_stones:
		var has_bagua_stone = false
		for slot in PlayerManager.INVENTORY_DATA.slots:
			if slot and slot.item_data and slot.item_data.resource_path == bagua_stone:
				has_bagua_stone = true
				break
		if not has_bagua_stone:
			has_all_bagua_stones = false
			break

	if has_all_bagua_stones:
		# 玩家背包中有足够的八卦石，执行交互逻辑
		print("玩家背包中有足够的八卦石，执行交互逻辑")
		# 删除玩家背包中的所有八卦石
		remove_bagua_stones_from_inventory()
		# 加载场景文件并实例化 item_pickup
		var item_pickup_scene = preload("res://Items/item_pickup/Bagua.tscn")
		var item_pickup = item_pickup_scene.instantiate()
		if item_pickup == null:
			print("错误: 无法实例化。")
			return
		# 设置 item_pickup 的属性
		item_pickup.item_data = preload("res://Items/longlin.tres")
		if item_pickup.item_data == null:
			print("错误: 无法加载 longlin.tres 资源。")
			return
		item_pickup.position = player.global_position
		get_parent().add_child(item_pickup)  # 将 item_pickup 添加到主场景中
		print("item_pickup 已成功添加到场景中。")
		PlayerManager.shake_camera(10)
		long_yin.play()
		await get_tree().create_timer(7.0).timeout ###时间长一点，玩家可以看到龙鳞
		get_tree().paused = true  # 暂停游戏
		BackpackMenu.hide() ###隐藏背包
		video_stream_player.play()
		
	else:
		# 玩家背包中没有足够的八卦石，提示玩家
		print("玩家背包中没有足够的八卦石")
		show_hint_label()

func show_hint_label() -> void:
	# 设置提示标签的文本
	hint_label.text = "你的背包中没有足够的八卦石"
	
	# 播放弹出动画
	animation_player.play("show_hint")
	
	# 在2秒后开始消失动画
	get_tree().create_timer(2.0).timeout.connect(_on_timer_timeout)

func _on_timer_timeout() -> void:
	# 播放消失动画
	animation_player.play("hide_hint")

func remove_bagua_stones_from_inventory() -> void:
	# 创建一个列表来存储需要移除的物品索引
	var items_to_remove = []
	
	# 遍历背包中的物品，找到所有需要移除的八卦石
	for i in range(PlayerManager.INVENTORY_DATA.slots.size()):
		var slot = PlayerManager.INVENTORY_DATA.slots[i]
		if slot and slot.item_data:
			for bagua_stone in bagua_stones:
				if slot.item_data.resource_path == bagua_stone:
					items_to_remove.append(i)
					break
	
	# 从后向前移除物品，避免在遍历过程中修改列表导致的问题
	for i in range(items_to_remove.size() - 1, -1, -1):
		var index = items_to_remove[i]
		PlayerManager.INVENTORY_DATA.remove_item(index)

func OnAreaEnter(_a: Area2D) -> void:
	PlayerManager.interact_pressed.connect(player_interact)

func OnAreaExit(_a: Area2D) -> void:
	PlayerManager.interact_pressed.disconnect(player_interact)

func _on_VideoStreamPlayer_finished():
	get_tree().change_scene_to_file("res://GUI/TitleScreen/TitleScreen.tscn")
