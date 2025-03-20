extends CanvasLayer

@onready var choice_panel: Control = $ChoicePanel
@onready var question_label: Label = $ChoicePanel/QuestionLabel
@onready var button_1: Button = $Control/Button
@onready var button_2: Button = $Control/Button2
@onready var button_3: Button = $Control/Button3
@onready var button_4: Button = $Control/Button4

var correct_answer = 1  # 假设第一个按钮是正确答案

# 显示选择题
func show_question(question: String, answers: Array, correct_index: int) -> void:
	choice_panel.visible = true
	question_label.text = question
	button_1.text = answers[0]
	button_2.text = answers[1]
	button_3.text = answers[2]
	button_4.text = answers[3]
	correct_answer = correct_index

	# 连接按钮点击事件并传递参数
	button_1.connect("pressed", Callable(self, "_on_answer_pressed").bind(1))
	button_2.connect("pressed", Callable(self, "_on_answer_pressed").bind(2))
	button_3.connect("pressed", Callable(self, "_on_answer_pressed").bind(3))
	button_4.connect("pressed", Callable(self, "_on_answer_pressed").bind(4))

# 玩家选择答案后的处理
func _on_answer_pressed(selected_answer: int) -> void:
	if selected_answer == correct_answer:
		print("Answer Correct!")
		emit_signal("answer_correct")  # 触发答案正确信号
		choice_panel.visible = false  # 隐藏选择题面板
	else:
		print("Answer Wrong!")
		# 可以显示一个提示或者动画，提示玩家答案错误
		choice_panel.visible = false  # 隐藏选择题面板
