tool
extends VBoxContainer


signal answer_added
signal selected(answer_name)
signal deselected(answer_name)


var prev_answer := ""


export (String, MULTILINE) var question_text = "Текст вопроса"


func _process(_delta):
	$Question.text = question_text
	if OS.get_name() == "HTML5" and $Answer.text != prev_answer:
		prev_answer = $Answer.text
		emit_signal("answer_added")


func _on_Answer_text_changed(_new_text):
	emit_signal("answer_added")


func _on_Answer_focus_entered():
	emit_signal("selected", name)


func _on_Answer_focus_exited():
	emit_signal("deselected", name)
