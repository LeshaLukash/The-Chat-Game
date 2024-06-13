extends Control


signal back_pressed


onready var ANSWERS_REQUIRED: int = get_node("%QuestionsList").get_child_count()


var correct_answers := {
	answer1 = ""
}

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		hide()
		emit_signal("back_pressed")


func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		hide()


func _on_BackButton_pressed():
	hide()
	emit_signal("back_pressed")


func check_answers_amount():
	var answers_given := 0
	for question in get_node("%QuestionsList").get_children():
		print(question.name + ": " + question.answer)
		if not question.answer.empty():
			answers_given += 1
	get_node("%EndReportButton").visible = (ANSWERS_REQUIRED == answers_given)


func _on_QuestionField1_answer_added():
	get_node("%QuestionField2").show()
	check_answers_amount()


func _on_QuestionField2_answer_added():
	get_node("%QuestionField3").show()
	check_answers_amount()


func _on_QuestionField3_answer_added():
	get_node("%QuestionField4").show()
	check_answers_amount()


func _on_QuestionField4_answer_added():
	get_node("%QuestionField5").show()
	check_answers_amount()


func _on_QuestionField5_answer_added():
	get_node("%QuestionField6").show()
	check_answers_amount()


func _on_QuestionField6_answer_added():
	check_answers_amount()
