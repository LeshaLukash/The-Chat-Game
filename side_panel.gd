tool
extends Control

signal chat_pressed
signal option_pressed
signal about_pressed
signal side_panel_dragged(weight)

const PANEL_POS_HIDED := -430
const PANEL_POS_SHOWED := 0

export (String) var account_name = "Имя аккаунта" setget _set_account_name
export (String) var chat_name = "Название беседы" setget _set_chat_name


func _ready():
	get_node("%AccountButton").text = account_name
	get_node("%ChatButton").text = chat_name
	

# Задать положение панели
func set_panel_pos(x: float) -> void:
	rect_position.x += x
	rect_position.x = clamp(rect_position.x, PANEL_POS_HIDED, PANEL_POS_SHOWED)


func unlock_report_button():
	get_node("%ReportButton").disabled = false



# Проиграть анимацию скрывания/выдвижения панели
func animate_panel(show_panel: bool) -> void:
	var tween: SceneTreeTween = get_tree().create_tween().set_trans(Tween.TRANS_BOUNCE)
	
	var result_panel_pos: int
	if show_panel:
		result_panel_pos = PANEL_POS_SHOWED
	else:
		result_panel_pos = PANEL_POS_HIDED
	
	# warning-ignore:return_value_discarded
	tween.tween_property(self, "rect_position:x", result_panel_pos, 0.2)


func _set_account_name(value: String):
	account_name = value
	if Engine.is_editor_hint():
		get_node("%AccountButton").text = account_name


func _set_chat_name(value: String):
	chat_name = value
	if Engine.is_editor_hint():
		get_node("%ChatButton").text = chat_name


func _on_ChatButton_pressed():
	emit_signal("chat_pressed")


func _on_OptionsButton_pressed():
	emit_signal("option_pressed")


func _on_AboutButton_pressed():
	emit_signal("about_pressed")


func _on_SidePanel_item_rect_changed():
	if not Engine.is_editor_hint():
		var weight: float = 1 - (rect_position.x / PANEL_POS_HIDED)
		emit_signal("side_panel_dragged", weight)
