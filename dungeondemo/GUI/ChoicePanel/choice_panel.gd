extends CanvasLayer

signal answer_correct

@onready var choice_panel: CanvasLayer = $"."
@onready var button_1: Button = $Control/Button
@onready var button_2: Button = $Control/Button2
@onready var button_3: Button = $Control/Button3
@onready var button_4: Button = $Control/Button4
@onready var question_label: Label = $Control/Label


var correct_answer = 1  # 假设第一个按钮是正确答案

# 显示选择题
func show_question(question: String, answers: Array, correct_index: int) -> void:
	# 断开之前的连接，避免重复绑定
	if button_1.is_connected("pressed", Callable(self, "_on_answer_pressed")):
		button_1.disconnect("pressed", Callable(self, "_on_answer_pressed"))
	if button_2.is_connected("pressed", Callable(self, "_on_answer_pressed")):
		button_2.disconnect("pressed", Callable(self, "_on_answer_pressed"))
	if button_3.is_connected("pressed", Callable(self, "_on_answer_pressed")):
		button_3.disconnect("pressed", Callable(self, "_on_answer_pressed"))
	if button_4.is_connected("pressed", Callable(self, "_on_answer_pressed")):
		button_4.disconnect("pressed", Callable(self, "_on_answer_pressed"))

	# 显示 UI
	choice_panel.visible = true
	question_label.text = question
	button_1.text = answers[0]
	button_2.text = answers[1]
	button_3.text = answers[2]
	button_4.text = answers[3]
	correct_answer = correct_index

	# 连接按钮点击事件并绑定参数
	button_1.connect("pressed", Callable(self, "_on_answer_pressed").bind(1))
	button_2.connect("pressed", Callable(self, "_on_answer_pressed").bind(2))
	button_3.connect("pressed", Callable(self, "_on_answer_pressed").bind(3))
	button_4.connect("pressed", Callable(self, "_on_answer_pressed").bind(4))

# 玩家选择答案后的处理
func _on_answer_pressed(selected_answer: int) -> void:
	if selected_answer == correct_answer:
		print("Answer Correct!")
		emit_signal("answer_correct")  # 触发答案正确信号
	else:
		print("Answer Wrong!")

	# 隐藏选择题面板
	choice_panel.visible = false
