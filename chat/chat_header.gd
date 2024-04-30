tool
extends Control

export (String) var chat_name = "Имя беседы" setget _set_chat_name

signal header_pressed

func _ready():
	get_node("%Label").text = chat_name

func _on_Button_pressed():
	print("Шапка чата была нажата")
	emit_signal("header_pressed")


func _set_chat_name(value: String):
	chat_name = value
	if Engine.is_editor_hint():
		get_node("%Label").text = chat_name
