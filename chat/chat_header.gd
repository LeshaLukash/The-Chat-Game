extends Control

signal header_pressed


func _on_Button_pressed():
	emit_signal("header_pressed")
