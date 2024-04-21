tool
extends Control

export (String) var text = "текст" setget set_text


func _ready():
	get_node("%Label").text = text


func set_text(value: String) -> void:
	text = value
