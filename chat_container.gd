tool
extends ScrollContainer
# ОКНО ЧАТА
# Это вертикальный список с прокруткой всех добавленых сообщений

const GROUP_MESSAGES_NAME := "messages"
const PARAMS_COUNT := 4

export (String, FILE, "*.txt") var chat_text_file = "res://chats/chat_example.txt" setget set_chat

onready var message_scene := preload("res://message.tscn")
onready var info_label_scene := preload("res://info_label.tscn")


func _ready():
	load_chat(chat_text_file)




# Прокрутить список сообщений на pos-пикселей
func scroll_messages(pos: float) -> void:
	scroll_vertical -= int(floor(pos)) 


# Загрузить чат из текстового файла, расположенного по пути chat_text_file
func load_chat(file_path: String = chat_text_file) -> void:
	clear_chat()
	
	# Извлекаем данные из файла
	var f = File.new()
	if not f.file_exists(file_path):
		printerr("Файл %s отсутствует!" %file_path)
		return
	f.open(file_path, File.READ)
	
	while f.get_position() < f.get_len():
		var line = f.get_line()
		
		# Угловыми скобками в чат вносят панели, отображающие дату отправления
		if line.begins_with('<') and line.ends_with('>'):
			add_info_panel(line)
		# В остальных случаях - перед нами сообщение
		else:
			# Считываем строку с параметрами сообщения
			var params: Dictionary = extract_params(line)
			
			# Если параметры не загрузились, или после них нет строки с текстом
			if params.empty() or f.eof_reached():
				clear_chat()
				printerr("Критическая ошибка при чтении %s, чат не загружен!" %file_path)
				return

			params.text = f.get_line().c_unescape()
			var is_last_msg: bool = f.eof_reached()
			add_message(params, is_last_msg)
	f.close()


# Добавить в чат инфопанель
func add_info_panel(line: String) -> void:
	var info_label = info_label_scene.instance()
	var info_label_text: String = line.trim_prefix('<')
	info_label_text = info_label_text.trim_suffix('>')
	info_label.set_text(info_label_text)
	$MessagesContainer.add_child(info_label)
	current_sender = ""
	previous_sender = ""


# Добавить в чат сообщение
var current_sender: String	# Имя отправителя текущего сообщения
var previous_sender: String	# Имя отправителя предыдущего сообщения
var current_msg: Message	# Обрабатываемое сообщение
var previous_msg: Message	# Обработанное ранее сообщение
var previous_msg_edited := false

func add_message(params: Dictionary, is_last_msg := false) -> void:
	current_msg = message_scene.instance()
	current_msg.add_to_group(GROUP_MESSAGES_NAME) # Добавляю в группу для упрощений массовой обработки
	
	# ОБРАБОТКА ПОСЛЕДОВАТЕЛЬНОСТИ СООБЩЕНИЙ
	# Если сообщение от лица того, от кого мы залогинены в системе
	if params.place_to_right == true:
		current_msg.set_h_size_flags(SIZE_SHRINK_END) # Сдвигаем к правому краю
		params.show_avatar = false
		params.show_sender_name = false
		
		# Если предыдущее сообщение было отредактировано во второй половине цикла
		# то отключаем у него отображение имени отправителя!
		if previous_msg_edited == true:
			previous_msg.show_sender_name = false
		previous_msg_edited = false
	
	# Если есть предыдущее сообщение
	elif previous_msg != null:
		# Если автор предыдущего сообщения тот же, что и текущего
		if previous_msg.sender == params.sender:
			# У первого сообщения отключаем только аватарку
			previous_msg.show_avatar = false
			
			# У остальных - ещё и имя
			if previous_msg_edited == false:
				previous_msg_edited = true
			else:
				previous_msg.show_sender_name = false
			
			# Если сообщение последнее - отключаем имя у текущего сообщения!
			if is_last_msg:
				params.show_sender_name = false
	
	previous_msg = current_msg

	current_msg.init_message(params)
	$MessagesContainer.add_child(current_msg)


# Удалить все сообщения из чата
func clear_chat() -> void:
	# Если группа пустая или отсутствует - завершаем функцию
	if get_tree().get_nodes_in_group(GROUP_MESSAGES_NAME).empty():
		return
	
	for message in get_tree().get_nodes_in_group(GROUP_MESSAGES_NAME):
		message.queue_free()


# Извлечь из строки параметры сообщения
func extract_params(string: String) -> Dictionary:
	var result := {
		"sender": "default",
		"text": "",
		"time": "",
		"is_edited": false,
		"place_to_right": false,
		"show_sender_name": true,
		"show_avatar": true
	}
	
	var params := string.split(',')
	# Если строка с параметрами имеет не 4 параметра - сбрасыываем чат
	if params.size() != PARAMS_COUNT:
		printerr("Ошибка при чтении строки с параметрами!")
		return {}
	
	result.sender = params[0]
	result.time = params[1]
	result.is_edited = bool(int(params[2]))
	result.place_to_right = bool(int(params[3]))
	
	return result
	
	
func set_chat(value: String) -> void:
	if value != chat_text_file:
		load_chat(value)
	
	chat_text_file = value
