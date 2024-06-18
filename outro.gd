extends Control

onready var ReportPercentLabel: Label = get_node("%ReportPercentLabel")
onready var ResumeLabel: Label = get_node("%ResumeLabel")


func calc_outro(percent: int) -> void:
	ReportPercentLabel.text = "Ваш отчёт оказался верен на %d %%." %percent
	
	var resume: String
	if percent in range(0, 10):
		resume = "Чат практически не изучен"
	elif percent in range(10, 24):
		resume = "Чат изучен поверхностно"
	elif percent in range(24, 46):
		resume = "Чат изучен более-менее"
	elif percent in range(46, 71):
		resume = "Чат изучен хорошо"
	elif percent in range(71, 100):
		resume = "Чат изучен целиком и полностью, но почему-то были допущены грубые промашки..."
	elif percent == 100:
		resume = "Чат изучен целиком и полностью, ни единой помарки!"
		
	ResumeLabel.text = resume
