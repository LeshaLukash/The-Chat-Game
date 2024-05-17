extends Control
# Главная сцена

const SAVE_PATH := "user://save_data.dat"


# Попытка активировать сенсорное управление
# при старте игры в браузере смартфона
func _init():
	if is_web_mobile():
		ProjectSettings.set_setting("input_devices/pointing/emulate_touch_from_mouse", true)


func _ready():
	$Intro.is_first_start = is_first_launch()
	if not is_first_launch():
		$Intro/StartButton.text = "Продолжить"
	$Intro.show()
	
	$Chat.set_process_input(false)
	$Intro.set_process_input(true)
	
	add_crime_date()
	$Chat/ChatContainer.load_chat()


# Код для проверки запуска игры из браузера смартфона
func is_web_mobile() -> bool:
	return JavaScript.eval("/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigation.userAgent)", true)


# Добавить в чат плашку с датой преступления
func add_crime_date() -> void:
	var f := File.new()
	var crime_date: String
	
	if is_first_launch():
		crime_date = $Chat/ChatContainer/DateCalculator.get_crime_date()
		# warning-ignore:return_value_discarded
		f.open(SAVE_PATH, File.WRITE)
		f.store_line(crime_date)
	else:
		# warning-ignore:return_value_discarded
		f.open(SAVE_PATH, File.READ)
		crime_date = f.get_line()
	f.close()
	$Chat/ChatContainer.add_info_panel(crime_date)


# Проверка, впервые ли запускается игра
func is_first_launch() -> bool:
	var f = File.new()
	return not f.file_exists(SAVE_PATH)


func _on_Intro_faded():
	$Chat.set_process_input(true)


func _on_Chat_report_pressed():
	$Chat.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Report.show()


func _on_Report_back_pressed():
	$Chat.mouse_filter = Control.MOUSE_FILTER_STOP
