extends Control

onready var ReportPercentLabel: Label = get_node("%ReportPercentLabel")
onready var ResumeLabel: Label = get_node("%ResumeLabel")
onready var ReportProgressBarTween: Tween = get_node("%ReportProgressBar/Tween")
onready var ReportProgressBar: ProgressBar = get_node("%ReportProgressBar")

func animate_outro(score: int) -> void:
	# warning-ignore:return_value_discarded
	ReportProgressBarTween.interpolate_property(ReportProgressBar, "value", 0, score, 5.0, Tween.TRANS_EXPO, Tween.EASE_OUT)
	# warning-ignore:return_value_discarded
	ReportProgressBarTween.start()


func update_outro(score: int) -> void:
	ReportPercentLabel.text = "Ваш отчёт оказался верен на %d %%." %score
	ResumeLabel.text = get_resume(score)


func set_progress_bar(score := 0) -> void:
	ReportProgressBar.value = score
	ReportProgressBar.show()


func get_resume(score: int = 0) -> String:
	var result := ""
	
	if score in range(0, 10):
		result = "Чат практически не изучен"
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


func show_labels() -> void:
	ReportPercentLabel.show()
	ResumeLabel.show()
	$Credits.show()


func _on_Tween_tween_completed(_object, _key):
	show_labels()
