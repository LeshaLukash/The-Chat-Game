tool
extends VBoxContainer


signal answer_added
signal hided_by_keyboard(screen_bias)
signal selected
signal deselected



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
	emit_signal("selected")
	yield(get_tree().create_timer(0.3), "timeout") # Клавиатура вылезает не сразу, даём ей на это время
	var virtual_keyboard_height: int = OS.get_virtual_keyboard_height() - 200
	var answer_field_pos: int = int($Answer.rect_global_position.y)
	
	#print("keyboard keight is %d, field pos is %d" %[virtual_keyboard_height, answer_field_pos])
	
	if virtual_keyboard_height > 0 and virtual_keyboard_height < answer_field_pos:
		var screen_bias: int = virtual_keyboard_height - $Answer.rect_global_position.y
		emit_signal("hided_by_keyboard", screen_bias)


func _on_Answer_focus_exited():
	emit_signal("deselected")
