extends Control

signal back_pressed

var correct_answers := {
	chat_name = "игра на выбывание",
	total_players = 5,
	players_nicknames = [],
	victim_nickname = "saxxxy13",
	killer_nickname = ""
}

var player_answers := {
	chat_name = "",
	total_players = 0,
	players_nicknames = [],
	victim_nickname = "",
	killer_nickname = ""
}


func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		hide()
		emit_signal("back_pressed")


func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		hide()


# Игрок ввёл текст в поле ответа нв вопрос 1 - показать кнопку подтверждения
func _on_Answer1_text_changed(new_text):
	if not new_text.empty():
		get_node("%Button1").show()
	else:
		get_node("%Button1").hide()


func _on_Button1_pressed():
	player_answers["chat_name"] = get_node("%Answer1").text
	
	# Если при нажатии "подтвердить" поле с ответом не пустое - показать вопрос 2
	if not player_answers["chat_name"].empty():
		get_node("%Question2").show()
		get_node("%Answer2").show()
		get_node("%MarginContainer2").show()
	
	# Если игрок ввёл правильный ответ - скрыть кнопку подтверждения
	if player_answers["chat_name"].to_lower() == correct_answers["chat_name"]:
		get_node("%Answer1").editable = false
		get_node("%Button1").hide()


func _on_BackButton_pressed():
	hide()
	emit_signal("back_pressed")
