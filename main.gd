extends Control
# Главная сцена

const SAVE_DATE := "user://save_date.dat"
const SAVE_PLAYER_ANSWERS := "user://save_player_answers.dat"


# Здесь хранятся ответы игрока
var player_answers := {
	answer1 = "",
	answer2 = "",
	answer3 = "",
	answer4 = "",
	answer5 = "",
	answer6 = ""
}


# Попытка активировать сенсорное управление
# при старте игры в браузере смартфона
func _init():
	if is_web_mobile():
		ProjectSettings.set_setting("input_devices/pointing/emulate_touch_from_mouse", true)


func _ready():
	$Intro.is_first_start = is_first_launch()
	if not is_first_launch():
		$Intro/BeginButton.text = "Продолжить"
	$Intro.show()
	
	$Chat.set_process_input(false)
	$Intro.set_process_input(true)
	
	add_crime_date()
	load_player_answers()
	$Report.check_answers_amount()
	$Chat/ChatContainer.load_chat()


func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and not $Report.visible:
		get_tree().quit()


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
		f.open(SAVE_DATE, File.WRITE)
		f.store_line(crime_date)
	else:
		# warning-ignore:return_value_discarded
		f.open(SAVE_DATE, File.READ)
		crime_date = f.get_line()
	
	f.close()
	$Chat/ChatContainer.add_info_panel(crime_date)


# Загружаем сохранённые ответы
func load_player_answers() -> void:
	var f = File.new()
	if not f.file_exists(SAVE_PLAYER_ANSWERS):
		return
	
	f.open(SAVE_PLAYER_ANSWERS, File.READ)
	for key in player_answers.keys():
		player_answers[key] = f.get_line()
	
	# Записываем загруженные ответы в поля отчёта
	var answer_current_number: int = 1
	for question in $Report.get_node("%QuestionsList").get_children():
		var answer_key: String = "answer" + str(answer_current_number)
		question.answer = player_answers[answer_key]
		answer_current_number += 1


# Сохраняем ответы игрока
func save_player_answers() -> void:
	var f = File.new()
	f.open(SAVE_PLAYER_ANSWERS, File.WRITE)
	for value in player_answers.values():
		f.store_line(value)


# Проверка, впервые ли запускается игра
func is_first_launch() -> bool:
	var f = File.new()
	return not f.file_exists(SAVE_DATE)


func _on_Intro_faded():
	$Chat.set_process_input(true)


func _on_Chat_report_pressed():
	$Chat.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Report.show()


func _on_Report_back_pressed():
	$Chat.mouse_filter = Control.MOUSE_FILTER_STOP


func _on_Report_report_filled():
	$Outro.calc_outro($Report.check_correct_answers())
	$Chat.hide()
	$Intro.hide()
	$Outro.show()


func _on_Report_answer_added(answer_name, answer):
	player_answers[answer_name] = answer
	save_player_answers()
