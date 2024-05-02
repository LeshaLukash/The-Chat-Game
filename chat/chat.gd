extends Control

# Окно чата
const FADE_MAX := 150 				# Макс. затенение экрана сообщений
const DRAG_LENGTH := 3				# Макс. длина свайпа, после чего проверяется его назначение
const INERTIA_SCROLL_SPEED := 0.5	# Скорость прокрутки сообщений после того, как игрок отпустил палец
const INERTIA_HIDDEN_SCROLL_SPEED := 3

var is_drag_started := false		# Флаг, начал ли игрок протягивать пальцем по экрану
var scroll_speed := 0.0				# Скорость прокрутки сообщений
var can_inert_scroll: bool


func _process(_delta):
	pass


# Отслеживаем свайпы по экрану
func _input(event):
	pass


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
