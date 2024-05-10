tool
extends ScrollContainer
# ОКНО ЧАТА
# Это вертикальный список с прокруткой всех добавленых сообщений

const GROUP_MESSAGES_NAME := "messages"	# Имя группы, содержащей все сообщения
const PARAMS_COUNT := 4					# Кол-во параметров у загружаемых сообщений
const INERT_SPEED_DECREASE := 50		# Скорость замедления прокрутки по инерции

export (String, FILE, "*.txt") var chat_text_file = "res://scripts/chat_example.txt"

onready var message_scene := preload("res://message/message.tscn")
onready var info_label_scene := preload("res://message/info_label.tscn")


func _ready():
	load_chat(chat_text_file) # загружаем чат
	get_v_scrollbar().self_modulate = Color(1, 1, 1, 0.5) # делаем вертикальый ползунок прозрачнее
	set_process(false) # не даём старотвать _ready


# Алгоритм работы инертой прокрутки
# Мы получаем скорость прокрутки, и уменьшаем её на 0.5
# Баг: возможна зависимость от скорости работы процессора!
func _process(delta):
	printt(inert_scroll_speed, scroll_vertical)
	if is_zero_approx(inert_scroll_speed):
		inert_scroll_speed = 0
		inert_scroll_dir = 0
		set_process(false)
	
	if scroll_vertical < get_chat_length() and scroll_vertical > 0:
		scroll_messages(inert_scroll_speed * delta)
		inert_scroll_speed -= INERT_SPEED_DECREASE * sign(inert_scroll_speed)
		if inert_scroll_dir < 0:
			inert_scroll_speed = clamp(inert_scroll_speed, inert_scroll_speed, 0)
		else:
			inert_scroll_speed = clamp(inert_scroll_speed, 0, inert_scroll_speed)
	else:
		inert_scroll_speed = 0


# Получить длину чата
# ВАЖНО: Не работает при вызове из _ready
# т.к. вертикальный ползунок медленно настраивается движком
func get_chat_length() -> float:
	return get_v_scrollbar().max_value - rect_size.y


# Активация инертного пролистывания сообщеий 
var inert_scroll_speed := 0.0
var inert_scroll_dir := 0.0
func inert_scroll_messages(i: float) -> void:
	inert_scroll_speed = round(i)
	inert_scroll_dir = sign(i)
	set_process(true)


# Прокрутить список сообщений на pos-пикселей
func scroll_messages(pos: float) -> void:
	scroll_vertical -= int(round(pos)) 


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


# Добавить в чат разделитель между сообщениями
func add_message_divider() -> void:
	var margin_container = MarginContainer.new()
	margin_container.add_constant_override("margin_bottom", 5)
	$MessagesContainer.add_child(margin_container)
	

# Добавить в чат сообщение
var current_sender: String	# Имя отправителя текущего сообщения
var previous_sender: String	# Имя отправителя предыдущего сообщения
var current_msg: Message	# Обрабатываемое сообщение
var previous_msg: Message	# Обработанное ранее сообщение
var previous_msg_edited := false

func add_message(params: Dictionary, is_last_msg := false) -> void:
	current_msg = message_scene.instance()
	# Добавляю в группу для упрощений массовой обработки
	current_msg.add_to_group(GROUP_MESSAGES_NAME)
	
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
			if previous_msg_edited == false:
				previous_msg_edited = true
				
			# У остальных - ещё и имя
			else:
				previous_msg.show_sender_name = false
			
			# Если сообщение самое последнее
			# то включаем имя у текущего сообщения!
			if is_last_msg:
				params.show_sender_name = false
		else:
			add_message_divider()
			if previous_msg_edited:
				previous_msg.show_sender_name = false
				previous_msg_edited = false
	
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
