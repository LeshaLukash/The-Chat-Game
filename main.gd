extends Control
# Главная сцена

const SAVE_DATE := "user://save_date.dat"
const SAVE_PLAYER_ANSWERS := "user://save_player_answers.dat"
const REPORT_SAVE_PATH := "user://report_save.dat"


var crime_date: String

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
	# Отключаем реакцию чата и включаем реакцию интро на ввод
	$Chat.set_process_input(false)
	$Intro.set_process_input(true)
	
	# Проверка, первый ли запуск и была ли игра завершена ранее
	$Intro.is_first_start = is_first_launch()
	var score = get_report_score()
	
	if not is_first_launch():
		$Intro/BeginButton.text = "Продолжить"
		
	if score > -1: # Если отчёт был составлен и подтверждён
		$Intro/BeginButton.text = "Посмотреть итоги"
		$Chat.hide()
		$Outro.show()
		$Outro.update_outro(score)
		$Outro.show_outro_immeditely(score)
		$Outro.get_node("%ResumeLabel").show()
		$Outro.get_node("%ReportPercentLabel").show()
	else: # Отчёта нет - игрок может вернуться к чату
		load_player_answers()
		$Report.check_answers_amount()
		add_crime_date()
		$Chat/ChatContainer.load_chat()
	$Intro.show()


# Если игрок нажимает на Android кнопку назад
func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and not $Report.visible:
		get_tree().quit()


# Код для проверки запуска игры из браузера смартфона
func is_web_mobile() -> bool:
	return JavaScript.eval("/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigation.userAgent)", true)


# Добавить в чат плашку с датой преступления
func add_crime_date() -> void:
	var f := File.new()
	
	if is_first_launch():
		crime_date = $Chat/ChatContainer/DateCalculator.get_crime_date()
		# warning-ignore:return_value_discarded
	else:
		# warning-ignore:return_value_discarded
		f.open(SAVE_DATE, File.READ)
		crime_date = f.get_line()
	
	f.close()
	$Chat/ChatContainer.add_info_panel(crime_date)


# Записать на память устройства дату преступления
func save_crime_date() -> void:
	var f := File.new()
	f.open(SAVE_DATE, File.WRITE)
	f.store_line(crime_date)
	f.close()


# Загружаем сохранённые ответы
func load_player_answers() -> void:
	var f = File.new()
	if not f.file_exists(SAVE_PLAYER_ANSWERS):
		f.close()
		return
	
	f.open(SAVE_PLAYER_ANSWERS, File.READ)
	for key in player_answers.keys():
		player_answers[key] = f.get_line()
	f.close()
	
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
	f.close()


# Сохраняем оценку игрока за составленный отчёт
func save_report_status(score: int) -> void:
	var f = File.new()
	f.open(REPORT_SAVE_PATH, File.WRITE)
	f.store_line(str(score))
	f.close()


# Заапрос оценки отчёта игрока. Если -1 - отчёта ещё нет
# Проверка, был ли заполнен и подтверждён отчёт
func get_report_score() -> int:
	var f = File.new()
	if not f.file_exists(REPORT_SAVE_PATH):
		f.close()
		return -1 # файла нет
	
	f.open(REPORT_SAVE_PATH, File.READ)
	var score := int(f.get_line())
	f.close()
	
	return score


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


func _on_Report_report_filled(score: int):
	save_report_status(score)
	$Chat.hide()
	$Intro.hide()
	$Outro.show()
	$Outro.update_outro(score)
	$Outro.animate_outro(score)


func _on_Report_answer_added(answer_name, answer):
	player_answers[answer_name] = answer
	save_player_answers()


func _on_Intro_pressed():
	save_crime_date()
