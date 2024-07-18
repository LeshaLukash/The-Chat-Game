extends Control

onready var ReportPercentLabel: Label = get_node("%ReportPercentLabel")
onready var ResumeLabel: Label = get_node("%ResumeLabel")
onready var ReportProgressBarTween: Tween = get_node("%ReportProgressBar/Tween")
onready var ReportProgressBar: ProgressBar = get_node("%ReportProgressBar")


# Запускает цепочку анимаций экрана итогов
func animate_outro(score: int) -> void:
	# warning-ignore:return_value_discarded
	ReportProgressBarTween.interpolate_property(ReportProgressBar, "value", 0, score, 5.0, Tween.TRANS_EXPO, Tween.EASE_OUT)
	# warning-ignore:return_value_discarded
	ReportProgressBarTween.start()


func update_outro(score: int) -> void:
	ReportPercentLabel.text = "Ваш отчёт оказался верен на %d %%." %score
	ResumeLabel.text = get_resume(score)


func show_outro_immeditely(score := 0) -> void:
	ReportProgressBar.value = score
	ReportProgressBar.show()
	
	ReportPercentLabel.self_modulate.a = 1
	$ReportProgressContainer.rect_position.y -= 400
	
	ResumeLabel.self_modulate.a = 1
	$Credits.self_modulate.a = 1
	


func get_resume(score: int = 0) -> String:
	var result := ""
	
	if score in range(0, 10):
		result = "Отчёт оказался полностью провальным.\n\nБыли допущены грубейшие ошибки, к моменту, когда их удалось исправить, было слишком поздно - все участники были мертвы, а организаторы бесследно исчезли, подчистив места гибели участников. Следствие снова зашло в тупик.\n\nВаши коллеги недоумевают, как можно было настолько небрежно подойти к делу, а руководство всерьёз задумывается если не об вашем увольнении, то по крайней мере понижении в должности.\n\nХуже того, ваше небрежное расследование не осталось незамеченными организаторами этих игр, и они, похоже, вышли на ваш след!\n\nБерегите себя."
	elif score in range(10, 24):
		result = "Чат изучен поверхностно"
	elif score in range(24, 46):
		result = "Чат изучен более-менее"
	elif score in range(46, 71):
		result = "Чат изучен хорошо"
	elif score in range(71, 100):
		result = "Чат изучен целиком и полностью, но почему-то были допущены грубые промашки..."
	elif score == 100:
		result = "Чат изучен целиком и полностью, ни единой помарки!"
	
	return result


func _on_ReportProgressBar_tween_completed(_object, _key):
	ReportPercentLabel.get_node("Tween").interpolate_property(ReportPercentLabel, "self_modulate:a", 0, 1, 1.0)
	ReportPercentLabel.get_node("Tween").start()
	
	$ReportProgressContainer/Tween.interpolate_property($ReportProgressContainer, "rect_position:y", $ReportProgressContainer.rect_position.y, $ReportProgressContainer.rect_position.y - 400, 1.0, Tween.TRANS_EXPO, Tween.EASE_OUT)
	$ReportProgressContainer/Tween.start()
	
	$ResumeLabel/Tween.interpolate_property($ResumeLabel, "self_modulate:a", 0, 1, 2.0)
	$ResumeLabel/Tween.start()


func _on_ReportProgressContainer_tween_completed(_object, _key):
	pass # Replace with function body.


func _on_ResumeLabel_tween_completed(_object, _key):
	$Credits/Tween.interpolate_property($Credits, "self_modulate:a", 0, 1, 3.0)
	$Credits/Tween.start()
