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


func _on_Answer1_text_entered(new_text):
	player_answers["chat_name"] = new_text
	if not new_text.empty():
		get_node("%Question2").show()
		get_node("%Answer2").show()
		get_node("%MarginContainer2").show()


func _on_Answer2_text_entered(new_text):
	player_answers["total_players"] = int(new_text)
	print(player_answers["total_players"])
	if not new_text.empty():
		get_node("%Question3").show()
		get_node("%Answer3").show()
		get_node("%MarginContainer3").show()


func _on_Answer3_text_entered(new_text):
	player_answers["players_nicknames"] = new_text.split(',', false)
	
