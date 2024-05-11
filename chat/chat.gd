extends Control

# Окно чата
const FADE_MAX := 150 			# Макс. затенение экрана сообщений
const DRAG_LENGTH := 15			# Макс. длина свайпа, после чего проверяется его назначение
const TIME_PRESS_SCREEN_STOP_INERTIA := 0.05


# Отслеживаем свайпы по экрану
var drag_vec := Vector2.ZERO

func _input(event):
	# Если пользователь начал проводить пальцем по экрану
	if event is InputEventScreenDrag:
		# Сперва пользователь должен провести пальцем вектор опред. длины
		if not is_drag_action_decided():
			drag_vec += event.relative
			
		# Проверяем, вектор вытянут в длину или в ширину
		# Если в ширину - отодвигаем боковую панель
		elif is_drag_horizontal():
			$SidePanel.set_panel_pos(event.relative.x)
			
		# Если в длину - скроллим сообщения
		elif not is_side_panel_visible():
			$ChatContainer.scroll_messages(event.relative.y)

	elif event is InputEventScreenTouch:
		# TODO: Пользователь нажал на экран - инициируем прерывание пролистывания по инерции
		if event.pressed:
			pass
		# Если пользователь отпустил палец
		else:
			# Перед тем, как отпустить палец, пользователь нарисовал вектор нужной длины
			if is_drag_action_decided():
				# Если да, и вектор горизонтальный - анимируем боковую панель
				if is_drag_horizontal():
					$SidePanel.animate_panel(is_side_panel_visible())
				# TODO: Если да, и вектор вертикальный - запускаем прокрутку по инерции
				elif not is_side_panel_visible():
					pass
			drag_vec = Vector2.ZERO


func is_drag_horizontal() -> bool:
	return abs(drag_vec.x) > abs(drag_vec.y)


func is_drag_action_decided() -> bool:
	return drag_vec.length() >= DRAG_LENGTH


# Проверка, видна ли боковая панель
func is_side_panel_visible() -> bool:
	return $SidePanel.rect_position.x / $SidePanel.rect_size.x >= -0.5


# Затеняем сообщения
func fade_messages(weight: float) -> void:
	$FadeRect.color.a8 = lerp(0, FADE_MAX, weight)
	
	# Если сообщения хотя бы немного затенены - не давать их нажимать
	if $FadeRect.color.a8 != 0:
		$FadeRect.mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		$FadeRect.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _on_SidePanel_side_panel_dragged(weight: float):
	fade_messages(weight)


func _on_ChatHeader_header_pressed():
	$SidePanel.animate_panel(not is_side_panel_visible())


func _on_SidePanel_chat_pressed():
	$SidePanel.animate_panel(not is_side_panel_visible())
