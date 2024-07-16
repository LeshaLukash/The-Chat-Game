extends Control


const SAVE_PATH := "user://save_data.dat"


signal answer_added(answer_name, answer)
signal back_pressed
signal report_filled(score)

onready var screen_size: Vector2 = OS.get_screen_size()
onready var ANSWERS_REQUIRED: int = get_node("%QuestionsList").get_child_count() # Кол-во ответов, которые должен дать игрок

# Словарь с правильными ответами
var correct_answers := {
	answer1 = "охота на сокровища",
	answer2 = [6, "шесть"],
	answer3 = "bloody_mary01",
	answer4 = "джеймс",
	answer5 = ["крейга41", "крейга,41", "крейга 41", "крейга, 41"],
	answer6 = ["финнеа34", "финеа34", "финнеа,34", "финеа,34", "финнеа 34", "финеа 34", "финеа, 34", "финнеа, 34"]
}

# Выделенное поле ответа
var current_question_selected: VBoxContainer = null


func _process(_delta):
	if is_virtual_keyboard_visible() and current_question_selected != null:
		var answer_origin: Vector2 = current_question_selected.get_global_transform_with_canvas().get_origin()
		print("game size: %s, screen_size: %s, keyboard height: %d, answer_origin: %s" %[str(get_tree().get_root().size), str(screen_size), OS.get_virtual_keyboard_height(), str(answer_origin)])
	else:
		rect_global_position.y = 0


func is_virtual_keyboard_visible() -> bool:
	# Если высота экранной клавитуры больше 0 - она видна
	return OS.get_virtual_keyboard_height() > 0


# Отслеживание нажатия кнопки "Назад" на Android
func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_on_BackButton_pressed()


func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		hide()


# Подсчитываем кол-во данных ответов
func check_answers_amount() -> void:
	var answers_given := 0
	var questions = get_node("%QuestionsList").get_children()
	
	for i in questions.size():
		if not questions[i].answer.empty():
			answers_given += 1
			questions[i].show()
			if i != questions.size() - 1:
				questions[i + 1].show()
	
	get_node("%EndReportButton").visible = (ANSWERS_REQUIRED == answers_given)


func does_save_exist() -> bool:
	var f = File.new()
	return f.file_exists(SAVE_PATH)


func check_correct_answers() -> int:
	var result := 0
	for question in get_node("%QuestionsList").get_children():
		print(question.answer + "\n")
		match question.name:
			"QuestionField1":
				if question.answer.to_lower() == correct_answers["answer1"]:
					result += 1
			"QuestionField2":
				var answer_int := int(question.answer)
				var answer_str: String = question.answer.to_lower()
				if correct_answers["answer2"].has(answer_int) or\
					correct_answers["answer2"].has(answer_str):
						result += 9
			"QuestionField3":
				if question.answer.to_lower() == correct_answers["answer3"]:
					result += 15
			"QuestionField4":
				if question.answer.to_lower() == correct_answers["answer4"]:
					result += 22
			"QuestionField5":
				var answer: String = question.answer.to_lower().lstrip("улица.,").dedent()
				if correct_answers["answer5"].has(answer):
					result += 23
			"QuestionField6":
				var answer: String = question.answer.to_lower().lstrip("улица,.").dedent()
				if correct_answers["answer6"].has(answer):
					result += 30
	print("Ваш результат: " + str(result))
	return result


func _on_BackButton_pressed():
	hide()
	emit_signal("back_pressed")


func _on_QuestionField1_answer_added():
	var question = get_node("%QuestionField1")
	get_node("%QuestionField2").show()
	emit_signal("answer_added", "answer1", question.answer)
	check_answers_amount()


func _on_QuestionField2_answer_added():
	var question = get_node("%QuestionField2")
	get_node("%QuestionField3").show()
	emit_signal("answer_added", "answer2", question.answer)
	check_answers_amount()


func _on_QuestionField3_answer_added():
	var question = get_node("%QuestionField3")
	get_node("%QuestionField4").show()
	emit_signal("answer_added", "answer3", question.answer)
	check_answers_amount()


func _on_QuestionField4_answer_added():
	var question = get_node("%QuestionField4")
	get_node("%QuestionField5").show()
	emit_signal("answer_added", "answer4", question.answer)
	check_answers_amount()


func _on_QuestionField5_answer_added():
	var question = get_node("%QuestionField5")
	get_node("%QuestionField6").show()
	emit_signal("answer_added", "answer5", question.answer)
	check_answers_amount()


func _on_QuestionField6_answer_added():
	var question = get_node("%QuestionField6")
	emit_signal("answer_added", "answer6", question.answer)
	check_answers_amount()


func _on_EndReportButton_pressed():
	# warning-ignore:return_value_discarded
	$WarningPopup.popup_centered()
	$ReportContainer.hide()
	$HeaderPanelContainer.hide()


func _on_YesButton_pressed():
	emit_signal("report_filled", check_correct_answers())
	$WarningPopup.hide()
	hide()


func _on_GoBackButton_pressed():
	$WarningPopup.hide()
	$ReportContainer.show()
	$HeaderPanelContainer.show()


func _on_QuestionField_selected(field_name: String):
	# Получаем текущее выделенное поле ввода
	current_question_selected = get_node("%%%s" %field_name)


func _on_QuestionField_deselected(_field_name: String):
	current_question_selected = null
