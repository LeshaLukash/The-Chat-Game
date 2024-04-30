extends Control

# Окно чата
const FADE_MAX := 150 				# Макс. затенение экрана сообщений
const DRAG_LENGTH := 3				# Макс. длина свайпа, после чего проверяется его назначение
const INERTIA_SCROLL_SPEED := 0.5	# Скорость прокрутки сообщений после того, как игрок отпустил палец
const INERTIA_HIDDEN_SCROLL_SPEED := 3

var drag_vector := Vector2.ZERO		# Вектор перемещения пальцем по экрану
var is_drag_started := false		# Флаг, начал ли игрок протягивать пальцем по экрану
var scroll_speed := 0.0				# Скорость прокрутки сообщений
var can_inert_scroll: bool


func _process(_delta):
	var scroll_slowing_speed: float
	
	if scroll_speed != 0:
		if is_drag_started:
			scroll_slowing_speed = INERTIA_HIDDEN_SCROLL_SPEED
		else:
			scroll_slowing_speed = INERTIA_SCROLL_SPEED
		
		scroll_speed -= scroll_slowing_speed * sign(scroll_speed)
		
	
	if can_inert_scroll:
		$ChatContainer.scroll_messages(scroll_speed)


# Отслеживаем свайпы по экрану
func _input(event):
	var is_drag_checked: bool
	var is_drag_horizontal: bool
	
	if event is InputEventScreenTouch or InputEventScreenDrag:
		is_drag_checked = drag_vector.length() >= DRAG_LENGTH
		is_drag_horizontal = abs(drag_vector.x) > abs(drag_vector.y)
	
	# Что должно произойти, когда игрок отпустил палец
	if event is InputEventScreenTouch:
		if event.pressed:
			scroll_speed = 0
			can_inert_scroll = false
		else:
			can_inert_scroll = true
			is_drag_started = false
			drag_vector = Vector2.ZERO
			
			if is_drag_checked and is_drag_horizontal:
				$SidePanel.animate_panel(is_side_panel_visible())

	elif event is InputEventScreenDrag:
		is_drag_started = true
		scroll_speed = 0.0
		
		# Игрок пальцем намечает вектор направления
		if is_drag_checked:
			# Когда drag_vector достигает определённой длины - проверяем, он вертикальный, или горизонтальный
			if is_drag_horizontal:
				$SidePanel.set_panel_pos(event.relative.x)
			elif not is_side_panel_visible():
				$ChatContainer.scroll_messages(event.relative.y)
				scroll_speed = event.speed.y * get_process_delta_time()
		else:
			drag_vector += event.relative


# Проверка, видна ли боковая панель
func is_side_panel_visible() -> bool:
	return $SidePanel.rect_position.x / $SidePanel.rect_size.x >= -0.5


# Затеняем сообщения
func fade_messages(weight: float) -> void:
	$FadeRect.color.a8 = lerp(0, FADE_MAX, weight)
	
	# Если сообщения хотя бы немного затенены - не давать их нажимать
	if $FadeRect.color.a8 == 0:
		$FadeRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		$FadeRect.mouse_filter = Control.MOUSE_FILTER_STOP


func _on_SidePanel_side_panel_dragged(weight: float):
	fade_messages(weight)


func _on_ChatHeader_header_pressed():
	$SidePanel.animate_panel(not is_side_panel_visible())


func _on_SidePanel_chat_pressed():
	$SidePanel.animate_panel(not is_side_panel_visible())
