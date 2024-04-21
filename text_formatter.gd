tool
extends Node
# Служебный скрипт для комплексной обработки текста

const WORD_MAX_LENGTH := 18		# Макс. длина слова в русском языке (в символах!)
const SENDER_MAX_LENGTH := 40	# Макс. длина имени (в символах!)


# Разбить большую строку на строки поменьше (без переносов!)
func format_line(line: String, line_max_length: int, line_font: DynamicFont) -> Array:
	var result := []
	# Строка разбивается на массив из отдельных слов 
	var line_words: PoolStringArray = line.split(' ')
	var last_word_idx: int = get_array_last_idx(line_words)
	
	var str_tmp := "" # Хранит промежуточные этапы разбиения
	
	# Перебираем все слова в строке
	for word_idx in line_words.size():
		var word: String = line_words[word_idx]
		
		# Если текущее слово сликом длинное (вероятно, спам букв)
		if word.length() >= WORD_MAX_LENGTH:
			for ch in word:
				if get_line_pixel_length(str_tmp + ch, line_font) <= line_max_length:
					str_tmp += ch
				else:
					result.append(str_tmp)
					str_tmp = ch
		
		# Пытаемся пристроить слово в текущую строку, разместив после него пробел
		# если слово пустое - значит, на его месте должен быть пробел
		# шутка в том, что пустое слово поставится вместе с пробелом, которым оно и должно быть!
		elif get_line_pixel_length(str_tmp + word + ' ', line_font) <= line_max_length:
			str_tmp += word + ' '
		
		# Если влезает только слово, без пробела - смотрим, является ли само слово пробелом
		# от этого зависит конец текущей и начало след. строки
		elif get_line_pixel_length(str_tmp + word, line_font) <= line_max_length:
			if word != '':
				str_tmp += word
				result.append(str_tmp)
				str_tmp = ""
			else:
				result.append(str_tmp)
				str_tmp = " "
		
		# Если слово никак не влезает - добавлем имеющуюся строку в результат
		# а рабочую строку перезаписываем словом, которое не влезло
		elif get_line_pixel_length(str_tmp + word, line_font) > line_max_length:
			result.append(str_tmp)
			str_tmp = word + ' '
		
		# Если слово было последним - добавляю остатки str_tmp как новую строку
		if word_idx == last_word_idx:
			str_tmp = str_tmp.trim_suffix(" ")
			# Пустые строки лучше не добавлять - на их месте 
			# могут возникнуть переносы при форматировании текста
			if str_tmp != "":
				result.append(str_tmp)

	return result


# Вписать текст сообщения в облако сообщения
func format_text(text: String, line_max_length: int, text_font: DynamicFont) -> String:
	if text == "":
		return text
		
	var result := ""
	
	# Анализируем ИСХОДНЫЙ текст - набор строк, разбитых переносами.
	# Разбиваем текст на строки и перебираем их
	# (если строка одна, то смотрим лишь её)
	var text_lines: PoolStringArray = text.split('\n')
	var last_line_idx: int = get_array_last_idx(text_lines)
	
	for line_idx in text_lines.size():
		var line: String = text_lines[line_idx]
		
		# Если текущая строка не слишком длинная
		if get_line_pixel_length(line, text_font) <= line_max_length:
			result += line
			# Если строка не последняя - после неё будет перенос!
			if line_idx != last_line_idx:
				result += '\n'
		
		# Если строка слишком длинная
		else: 
			# Разбиваем строку на подстроки
			var line_formatted: Array = format_line(line, line_max_length, text_font)
			var last_string_idx: int = get_array_last_idx(line_formatted)
			
			for str_idx in line_formatted.size():
				var string: String = line_formatted[str_idx]
				result += string
				# Если подстрока не последняя - после неё будет перенос!
				if str_idx != last_string_idx:
					result += '\n'
				
			# Если подстрока не последняя - после неё будет перенос!
			if line_idx != last_line_idx:
				result += '\n'
	return result


func get_array_last_idx(a: Array):
	return a.size() - 1

# Получить длину строки, в пикселях
func get_line_pixel_length(string: String, font: DynamicFont) -> int:
	return int(font.get_string_size(string).x)


# Получить самую длинную строку в сообщении
func get_longest_text_line(text: String, text_font: DynamicFont) -> String:
	if get_lines_count(text) == 1:
		return text
	
	# Разбиваем текст построчно, заносим в массив
	var text_lines: PoolStringArray = text.split('\n') 
	var text_lines_sizes := []
	
	# Заполняем массив значениями длин (в пикселях!) строк исходного текста
	for line in text_lines:
		text_lines_sizes.append(get_line_pixel_length(line, text_font))
	
	# Индекс первой самой длинной строки
	var text_line_long_idx: int = text_lines_sizes.find(text_lines_sizes.max()) 
	var result: String = text_lines[text_line_long_idx]
	return result


# Получить число строк в сообщении
func get_lines_count(text: String) -> int:
	return text.count('\n') + 1
