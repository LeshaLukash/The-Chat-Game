extends Control

signal header_pressed

func _on_Button_pressed():
	print("Шапка чата была нажата")
	emit_signal("header_pressed")
