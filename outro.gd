extends Control

onready var ReportPercentLabel: Label = get_node("%ReportPercentLabel")
onready var ResumeLabel: Label = get_node("%ResumeLabel")
onready var ReportProgressBarTween: Tween = get_node("%ReportProgressBar/Tween")
onready var ReportProgressBar: ProgressBar = get_node("%ReportProgressBar")


# Запускает цепочку анимаций экрана итогов
func animate_outro(score: int) -> void:
	$TypingSound.play()
	# warning-ignore:return_value_discarded
	ReportProgressBarTween.interpolate_property(ReportProgressBar, "value", 0, score, 5.0, Tween.TRANS_EXPO, Tween.EASE_OUT)
	# warning-ignore:return_value_discarded
	ReportProgressBarTween.start()


func update_outro(score: int) -> void:
	var result_degree: String = TranslationServer.translate("REPORT_PERCENT_DESCRIPTION")
	var score_str: String = "%d%%" %score
	
	if TranslationServer.get_locale() == "en":
		result_degree = result_degree.insert(15, " " + score_str)
		ReportPercentLabel.text = result_degree
	else:
		ReportPercentLabel.text = result_degree + " " + score_str + "."
	
	ResumeLabel.text = get_resume(score)


func show_outro_immeditely(score := 0) -> void:
	ReportProgressBar.value = score
	ReportProgressBar.show()
	
	ReportPercentLabel.self_modulate.a = 1
	$ReportProgressContainer.rect_position.y = 90
	
	ResumeLabel.self_modulate.a = 1
	$Credits.self_modulate.a = 1
	$ExitGameButton.show()
	$ExitGameButton/Timer.start(1.0)


func get_resume(score: int = 0) -> String:
	var result := ""
	
	if score in range(0, 10):
		result = TranslationServer.translate("RESULT_ZERO")
	elif score in range(10, 24):
		result = TranslationServer.translate("RESULT_ONE")
	elif score in range(24, 46):
		result = TranslationServer.translate("RESULT_TWO")
	elif score in range(46, 71):
		result = TranslationServer.translate("RESULT_THREE")
	elif score in range(71, 100):
		result = TranslationServer.translate("RESULT_FOUR")
	elif score == 100:
		result = TranslationServer.translate("RESULT_FIVE")

	return result


# Поведение экрана после того, как заполнилась процентная полоска
func _on_ReportProgressBar_tween_completed(_object, _key):
	ReportPercentLabel.get_node("Tween").interpolate_property(ReportPercentLabel, "self_modulate:a",
			0, 1, 1.0)
	ReportPercentLabel.get_node("Tween").start()
	
	$ReportProgressContainer/Tween.interpolate_property($ReportProgressContainer, "rect_position:y",
			$ReportProgressContainer.rect_position.y, 90, 1.0, Tween.TRANS_EXPO, Tween.EASE_OUT)
	$ReportProgressContainer/Tween.start()
	
	ResumeLabel.get_node("Tween").interpolate_property(ResumeLabel, "self_modulate:a", 0, 1, 2.0)
	ResumeLabel.get_node("Tween").start()


func _on_ReportProgressContainer_tween_completed(_object, _key):
	pass # Replace with function body.


func _on_ResumeLabel_tween_completed(_object, _key):
	$Credits/Tween.interpolate_property($Credits, "self_modulate:a", 0, 1, 3.0)
	$Credits/Tween.start()


func _on_Credits_tween_completed(_object, _key):
	yield(get_tree().create_timer(2.0), "timeout")
	$ExitGameButton.show()
	$ExitGameButton/Timer.start(1.0)


func _on_ExitGameButton_pressed():
	get_tree().quit()


func _on_ExitGameButton_Timer_timeout():
	if $ExitGameButton.self_modulate.a >= 1:
		$ExitGameButton.self_modulate.a = 0
	else:
		$ExitGameButton.self_modulate.a = 1
	$ExitGameButton/Timer.start(1.0)
