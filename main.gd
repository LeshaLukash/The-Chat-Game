extends Control

const SAVE_PATH := "user://save_data.dat"

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


func is_first_launch() -> bool:
	var f = File.new()
	return not f.file_exists(SAVE_PATH)
