tool
extends VBoxContainer


signal answer_added
signal selected(answer_name)
signal deselected(answer_name)


var answer: String setget set_answer


export (String, MULTILINE) var question_text = "Текст вопроса"


func _process(_delta):
	$Question.text = question_text


func _on_Answer_text_changed(new_text):
	answer = new_text
	emit_signal("answer_added")


func set_answer(value: String) -> void:
	answer = value
	$Answer.text = answer


func _on_Answer_focus_entered():
	emit_signal("selected", name)


func _on_Answer_focus_exited():
	emit_signal("deselected", name)
