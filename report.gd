extends Control

signal back_pressed

var correct_answers := {
	chat_name = "игра на выбывание",
	total_players = 6,
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


func _on_BackButton_pressed():
	hide()
	emit_signal("back_pressed")
