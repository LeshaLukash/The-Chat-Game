tool
class_name Message
extends MarginContainer
## СООБЩЕНИЕ
# Поле с текстом сообщения

# Сигнал нажатия аватарки
signal avatar_pressed 

# Макс. длина строки сообщения, в пикселях
const LINE_MAX_LENGTH := 400

# Константы тегов, форматирующих имя отправителя и время в тексте сообщения
const TIME_TAGS_START := "[right][font=fonts/arial_time.tres]"
const TIME_TAGS_END := "[/font][/right]"
const SENDER_TAGS_START := "[color=#4977C6][font=fonts/arial_sender_name.tres]"
const SENDER_TAGS_END := "[/font][/color]"
const TEXT_TAGS_START := "[font=fonts/message_text_font.tres]"
const TEXT_TAGS_END := "[/font]"

# Файлы шрифтов имени, сообщения и времени
export (DynamicFont) var sender_font = preload("res://fonts/arial_sender_name.tres")
export (DynamicFont) var text_font = preload("res://fonts/message_text_font.tres")
export (DynamicFont) var time_font = preload("res://fonts/arial_time.tres")

# Строки имени, текста и времени
export (String) var sender = "Отправитель" setget set_sender
export (String, MULTILINE) var text setget set_text
export (String) var time = "00:00" setget set_time

# Маркер сообщения статусом "изменено"
export (bool) var is_edited = false setget set_edited
# Маркер, скрыть или показать имя отправителя
export (bool) var show_sender_name = true setget set_show_sender_name
# Маркер, отображать или скрыть аватарку
export (bool) var show_avatar = true setget set_show_avatar
# Текстура аватарки
export (StreamTexture) var avatar_texture


# Задать содержимое сообщения
func init_message(params: Dictionary):
	sender = params.sender
	avatar_texture = AvatarsDB.get_avatar(sender)
	text = params.text
	time = params.time
	is_edited = params.is_edited
	show_sender_name = params.show_sender_name
	show_avatar = params.show_avatar
	update_message()


# Обновить содержимое сообщения
func update_message() -> void:
	# Форматируем содержимое сообщения
	var sender_formatted: String = SENDER_TAGS_START + sender + SENDER_TAGS_END
	var text_formatted: String = $TextFormatter.format_text(text, LINE_MAX_LENGTH, text_font)
	var time_formatted: String = TIME_TAGS_START + get_time_status() + TIME_TAGS_END
	
	# Обновляем содержимое сообщения и подгоняем его под текст
	get_node("%Avatar").texture_normal = avatar_texture
	get_node("%Avatar").set_self_modulate(Color(1, 1, 1, float(show_avatar)))

	if show_sender_name == true:
		get_node("%Text").bbcode_text = sender_formatted + '\n' + TEXT_TAGS_START +\
				text_formatted + TEXT_TAGS_END + '\n' + time_formatted
	else:
		get_node("%Text").bbcode_text = TEXT_TAGS_START + text_formatted +\
				TEXT_TAGS_END + '\n' + time_formatted
	
	get_node("%Text").rect_min_size.x = calc_message_width(text_formatted)
	#get_node("%Text").rect_size.x = get_node("%Text").rect_min_size.x
	#get_node("%Panel").rect_size.x = 0.0


# Вычислить ширину сообщения, в зависимости от размера содержимого
func calc_message_width(text_formatted: String) -> int:
	
	var sender_length: int
	if show_sender_name == true:
		sender_length = $TextFormatter.get_line_pixel_length(sender, sender_font)
	else:
		sender_length = 0
	
	var text_longest_line: String = $TextFormatter.get_longest_text_line(text_formatted, text_font)
	var text_length: int = $TextFormatter.get_line_pixel_length(text_longest_line, text_font)
	var time_length: int = $TextFormatter.get_line_pixel_length(get_time_status(), time_font)
	
	var length_to_compare := [sender_length, text_length, time_length]
	var panel_width := int(ceil(clamp(length_to_compare.max(), 0, LINE_MAX_LENGTH)))
	return panel_width


# Получаем строку со временем + подписью "изменено" (если нужно)
func get_time_status() -> String:
	var result: String = time
	if is_edited:
		result += ", изменено"
	return result


#################### СЕТТЕРЫ ####################
func set_sender(value: String):
	if get_node_or_null("TextFormatter") != null:
		# Задаём имя, не превышающее по длине лимит
		sender = value.substr(0, $TextFormatter.SENDER_MAX_LENGTH - 1)
		update_message()


func set_text(value: String):
	text = value
	if get_node_or_null("TextFormatter") != null:
		update_message()


func set_edited(value: bool):
	is_edited = value
	if get_node_or_null("TextFormatter") != null:
		update_message()


func set_time(value: String):
	if value.empty():
		time = "00:00"
	else:
		time = value
	if get_node_or_null("TextFormatter") != null:
		update_message()


func set_show_sender_name(value: bool):
	show_sender_name = value
	if get_node_or_null("TextFormatter") != null:
		update_message()


func set_show_avatar(value: bool):
	show_avatar = value
	if get_node_or_null("TextFormatter") != null:
		update_message()


#################### СИГНАЛЫ ####################
func _on_Avatar_pressed():
	print("Аватарка отправителя была нажата")
	emit_signal("avatar_pressed")


func _on_Message_item_rect_changed():
	update_message()
