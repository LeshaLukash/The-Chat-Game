tool
extends VBoxContainer


signal answer_added


var answer: String

export (String, MULTILINE) var question_text = "Текст вопроса"


func _process(_delta):
	$Question.text = question_text


func _on_Answer_text_changed(new_text):
	answer = new_text
	emit_signal("answer_added")
