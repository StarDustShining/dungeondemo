extends Node2D

# 下落时间，音符提前多少秒生成
var fk_fall_time: float = 2.2

# 轨道数量6个，对应 num=1~6
const TRACK_COUNT = 6

# JSON文件路径
var json_file_path = "res://data/bell_hits.json"

# 声明存储音符数据的数组
var bell_hits = []

# 按num映射到轨道按钮名（对应你的按键映射）
var num_to_button = {
	1: "button_M",
	2: "button_N",
	3: "button_B",
	4: "button_V",
	5: "button_C",
	6: "button_X"
}

func _ready():
	# 读取并解析JSON文件
	if load_json(json_file_path):
		# 播放音乐
		$MusicPlayer.play()
	
		# 逐条事件调度生成音符
		for hit in bell_hits:
			var delay = hit["time"] - fk_fall_time
			var btn_name = num_to_button.get(hit["num"], "button_X") # 默认Q键防崩
			SpawnFallingKey(btn_name, delay)
	
func load_json(file_path: String) -> bool:
	# 创建 File 实例
	var file = File.new()
	
	# 打开文件进行读取
	if file.open(file_path, File.READ) != OK:
		print("无法打开文件: " + file_path)
		return false
	
	# 读取文件内容
	var json_data = file.get_as_text()
	
	# 关闭文件
	file.close()
	
	# 尝试解析 JSON 数据
	var parsed_data = JSON.parse(json_data)
	if parsed_data.error != OK:
		print("解析 JSON 失败！")
		return false
	
	# 获取解析后的数据
	bell_hits = parsed_data.result
	return true


func SpawnFallingKey(button_name: String, delay: float) -> void:
	# 如果延迟时间小于0，立刻生成（避免异常）
	if delay <= 0:
		Signals.CreateFallingKey.emit(button_name)
	else:
		# 延时调度
		await get_tree().create_timer(delay).timeout
		Signals.CreateFallingKey.emit(button_name)
