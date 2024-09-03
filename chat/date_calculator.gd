extends Node
# КАЛЬКУЛТОР ДАТЫ ПРЕСТУПЛЕНИЯ

const month_names_rus := [
		"января", "февраля", "марта",
		"апреля", "мая", "июня",
		"июля", "августа", "сентября",
		"октября", "ноября", "декабря"
		]
const month_names_eng := [
	"January", "February", "March", "April", "May", "June",
	"July", "August", "September", "October", "November", "December"]
const month_length := [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]


# Выведение дня происшествия (Предыдущий день от дня запуска игры)
func get_crime_date() -> String:
	var datetime := Time.get_datetime_dict_from_system()
	var day_current: int = datetime["day"]
	var month_current: int = datetime["month"]
	var year_current: int = datetime["year"]
	
	var day_crime: int
	var month_crime: int
	var year_crime: int
	
	if day_current == 1:
		if month_current != 1:
			month_crime = month_current - 1
			year_crime = year_current
		else:
			month_crime = Time.MONTH_DECEMBER
			year_crime = year_current - 1
			
		day_crime = month_length[month_crime - 1]
		if month_crime == Time.MONTH_FEBRUARY:
			if is_leap_year(year_crime):
				day_crime += 1
	else:
		day_crime = day_current - 1
		month_crime = month_current
		year_crime = year_current
	
	var month_name: String = month_names_rus[month_crime - 1]
	if false:
		month_name = month_names_eng[month_crime - 1]
	
	var result = str(day_crime) + " " + month_name + " " + str(year_crime)
	if false:
		result = month_name + " " + str(day_crime) + ", " + str(year_crime)
	
	return result


# Определяем, вискосый ли год
func is_leap_year(year: int) -> bool:
	if year % 4 == 0:
		if year % 100 == 0:
			if year % 400 == 0:
				return true
			else:
				return false
		else:
			return true
	else:
		return false
