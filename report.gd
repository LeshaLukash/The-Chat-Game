extends Control


const SAVE_PATH := "user://save_data.dat"
const VIRTUAL_KEYBOARD_CONST := 100


signal answer_added(answer_name, answer)
signal back_pressed
signal report_filled(score)


onready var game_screen_size: Vector2 = get_tree().get_root().size					# Размер экрана с игрой!
onready var ANSWERS_REQUIRED: int = 6	# Кол-во ответов, которые должен дать игрок
onready var os_name: String = OS.get_name()


# Словарь с правильными ответами
var correct_answers := {
	answer1 = ["охота на сокровища", "treasure hunt"],
	answer2 = [6, "шесть", "six"],
	answer3 = "bloody_mary01",
	answer4 = ["джеймс", "james"],
	answer5 = ["крейга41", "крейга,41", "крейга 41", "крейга, 41", "kraig41", "kraig,41", "kraig 41", "kraig, 41"],
	answer6 = ["финнеа34", "финеа34", "финнеа,34", "финеа,34", "финнеа 34", "финеа 34", "финеа, 34", "финнеа, 34"]
}

# Выделенное поле ответа
var current_question_selected: VBoxContainer = null


# Проверяем на мобильных устройствах 
# высоту мобильной клавиатуры
# и сравниваем её с координатами выделенного поля ввода ответа
# если разница мала - то вероятно, клавиатура перекрывает поля ввода
# тогда сдвигаем экран вверх на разницу между высотой вопроса и размером экрана, не занятого клавиатурой!
func _process(_delta):
	if os_name == "Android" or os_name == "iOS":
		if is_virtual_keyboard_visible() and current_question_selected != null:
			var free_screen_space := int(game_screen_size.y - OS.get_virtual_keyboard_height())
			var answer_screen_pos: Vector2 = get_viewport_transform().xform_inv(current_question_selected.get_node("Answer").rect_global_position)
			var screen_bias := int(free_screen_space - answer_screen_pos.y)
			
			# У виртуальных клавиатур бывают приблуды и панели, 
			# которые, видимо, годот не учитывает при подсчёте высоты клавиатуры
			# поэтому разница между положением поля ввода и пространством,
			# не занятым виртуальной клавиатурой, берётся с небольшим запасом
			if screen_bias < VIRTUAL_KEYBOARD_CONST and rect_global_position.y == 0:
				# в некоторых случаях screen_bias бывает отрицательным, поэтому берём по модулю
				rect_global_position.y -= abs(screen_bias) + VIRTUAL_KEYBOARD_CONST
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
		if not questions[i].get_node("Answer").text.empty():
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
		var answer = question.get_node("Answer").text

		match question.name:
			"QuestionField1":
				if answer.to_lower() == correct_answers["answer1"]:
					result += 1
			"QuestionField2":
				var answer_int := int(answer)
				var answer_str: String = answer.to_lower()
				if correct_answers["answer2"].has(answer_int) or\
					correct_answers["answer2"].has(answer_str):
						result += 9
			"QuestionField3":
				if answer.to_lower() == correct_answers["answer3"]:
					result += 15
			"QuestionField4":
				if answer.to_lower() == correct_answers["answer4"]:
					result += 22
			"QuestionField5":
				var answer_formatted: String = answer.to_lower().lstrip("улица.,").dedent()
				if correct_answers["answer5"].has(answer_formatted):
					result += 23
			"QuestionField6":
				var answer_formatted: String = answer.to_lower().lstrip("улица,.").dedent()
				if correct_answers["answer6"].has(answer_formatted):
					result += 30
	print("Ваш результат: " + str(result))
	return result


func _on_BackButton_pressed():
	hide()
	emit_signal("back_pressed")


func _on_QuestionField1_answer_added():
	var question: VBoxContainer = get_node("%QuestionField1")
	var answer: String = question.get_node("Answer").text
	get_node("%QuestionField2").show()
	emit_signal("answer_added", "answer1", answer)
	check_answers_amount()


func _on_QuestionField2_answer_added():
	var question = get_node("%QuestionField2")
	var answer: String = question.get_node("Answer").text
	get_node("%QuestionField3").show()
	emit_signal("answer_added", "answer2", answer)
	check_answers_amount()


func _on_QuestionField3_answer_added():
	var question = get_node("%QuestionField3")
	var answer: String = question.get_node("Answer").text
	get_node("%QuestionField4").show()
	emit_signal("answer_added", "answer3", answer)
	check_answers_amount()


func _on_QuestionField4_answer_added():
	var question = get_node("%QuestionField4")
	var answer: String = question.get_node("Answer").text
	get_node("%QuestionField5").show()
	emit_signal("answer_added", "answer4", answer)
	check_answers_amount()


func _on_QuestionField5_answer_added():
	var question = get_node("%QuestionField5")
	var answer: String = question.get_node("Answer").text
	get_node("%QuestionField6").show()
	emit_signal("answer_added", "answer5", answer)
	check_answers_amount()


func _on_QuestionField6_answer_added():
	var question = get_node("%QuestionField6")
	var answer: String = question.get_node("Answer").text
	emit_signal("answer_added", "answer6", answer)
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
