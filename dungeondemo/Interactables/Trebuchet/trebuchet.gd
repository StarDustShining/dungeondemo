extends Node2D

@onready var trebuchet_minigame: Node2D = $TrebuchetMinigame

# 根据完成时间计算投石机发射力度
var max_power = 1000.0   # 最大力度
var min_power = 200.0    # 最小力度
var scale_factor = 300.0 # 缩放系数，控制影响程度

#var launch_power = max_power - (completion_time * scale_factor)
#launch_power = clamp(launch_power, min_power, max_power)  # 确保力度在合理范围内
#
#print("投石机发射力度: ", launch_power)
