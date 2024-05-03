tool
extends Control

signal chat_pressed
signal option_pressed
signal about_pressed
signal side_panel_dragged(weight)

onready var panel_pos_hided := rect_position.x
onready var panel_pos_showed := 0.0


# Задать положение панели
func set_panel_pos(x: float) -> void:
	rect_position.x += x
	rect_position.x = clamp(rect_position.x, panel_pos_hided, panel_pos_showed)


func unlock_report_button():
	get_node("%ReportButton").disabled = false


# Проиграть анимацию скрывания/выдвижения панели
func animate_panel(show_panel: bool) -> void:
	var tween: SceneTreeTween = get_tree().create_tween().set_trans(Tween.TRANS_QUART)
	
	var result_panel_pos: float
	if show_panel:
		result_panel_pos = panel_pos_showed
	else:
		result_panel_pos = panel_pos_hided
	
	# warning-ignore:return_value_discarded
	tween.tween_property(self, "rect_position:x", result_panel_pos, 0.2)


func _on_ChatButton_pressed():
	emit_signal("chat_pressed")


func _on_OptionsButton_pressed():
	emit_signal("option_pressed")


func _on_AboutButton_pressed():
	emit_signal("about_pressed")


func _on_SidePanel_item_rect_changed():
	if not Engine.is_editor_hint():
		var weight: float = 1 - (abs(rect_position.x) / rect_size.x)
		emit_signal("side_panel_dragged", weight)


func _on_ExitButton_pressed():
	get_tree().quit()
