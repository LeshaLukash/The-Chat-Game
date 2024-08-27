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
	$ReportProgressContainer.rect_position.y = 90
	
	ResumeLabel.self_modulate.a = 1
	$Credits.self_modulate.a = 1
	$ExitGameButton.show()
	$ExitGameButton/Timer.start(1.0)


func get_resume(score: int = 0) -> String:
	var result := ""
	
	if score in range(0, 10):
		result = "Отчёт оказался полностью провальным. Были допущены грубейшие ошибки, к моменту, когда их удалось исправить, было слишком поздно - все участники были мертвы, а организаторы бесследно исчезли, подчистив места гибели участников. Следствие снова зашло в тупик.\n\nВаши коллеги недоумевают, как можно было настолько небрежно подойти к делу, а руководство всерьёз задумывается если не об вашем увольнении, то по крайней мере понижении в должности.\n\nХуже того, ваше небрежное расследование не осталось незамеченными организаторами этих игр, и они, похоже, вышли на ваш след!\n\nБерегите себя."
	elif score in range(10, 24):
		result = "Отчёт оказался провальным. Были допущены грубые ошибки, которые сбили расследование с толку. Когда их удалось исправить, было уже поздно - все участники игры были мертвы.\n\nПовезло, что организаторы не успели тщательно подчистить одно из мест преступления, благодаря чему удалось собрать немного информации об этих играх. Но этого оказалось недостаточно для развития дела. Организаторы вновь опередили нас, а следствие зашло в тупик.\n\nВаши коллеги недоумевают, как можно было столь небрежно подойти к делу, а руководство всерьёз задумывается если не об вашем увольнении, то, по крайней мере, понижении в должности.\n\nВ следующий раз провал недопустим."
	elif score in range(24, 46):
		result = "Отчёт оказался посредственным. Были допущены серьёзные ошибки, на исправление которых ушло очень много времени. К моменту, когда отчёт был приведён в порядок, все участники были мертвы.\n\nОднако есть и хорошие новости: организаторы не успели до конца подчистить несколько мест преступления! Это позволило собрать информацию об нескольких погибших участниках, и даже нашлась одна зацепка на одного из организаторов игр. Кажется, дело начинает сдвигаться с мёртвой точки...\n\nВ Вашем отделе расползаются слухи о Вашем халатном отношении к работе, а руководство всерьёз задумывается если не о понижении в должности, то, по крайней мере, об урезании зарплаты.\n\nСейчас удача на нашей стороне, но в следующий раз ошибки недопустимы."
	elif score in range(46, 71):
		result = "Отчёт оказался удовлетворительным. Были допущены ошибки, которые сбили следователей с толку. На их исправление ушло времени, которое, возможно, могло бы спасти хотя бы одну из жертв кровавых «игр». К несчастью, ни один из участников не выжил.\n\nОднако благодаря оперативной работе следователей, места происшествий не были подчищены должным образом. Собранной информации оказалось достаточно, чтобы начать расследование по поиску организаторов этих побоищ. Следствие сдвинулось с места и начинает набирать обороты.\n\nНесмотря на проделанную работу, некоторые ваши коллеги недовольны вашими результатами - они полагают, что при должном старании можно было кого-нибудь спасти. Руководство задумывается об лишении Вас премии за этот месяц.\n\nСейчас ситуация под контролем, но в будущем таких ошибок лучше не допускать."
	elif score in range(71, 100):
		result = "Отчёт превосходный! Были допущены некоторые ошибки, но они не вызвали проблем у следователей. Прибыв на остальные места преступления, им удалось спасти одного из участников этой игры. Несомненно, допусти Вы еще одну ошибку, он был бы мертв.\n\nЧерез некоторое время были найдены тела остальных жертв, однако организаторам игр удалось скрыться. Благодаря тому, что места преступления не успели сильно подчистить, следствие получило хорошую почву для расследования благодаря обнаруженным зацепкам и уликам. Начато большое расследование.\n\nВаши коллеги одобрительно кивают головой, ведь Вам удалось спасти чужую жизнь, однако дело всё ещё не полностью раскрыто, так что премия в этом месяце маловероятна.\n\nВ следующий раз внимательнее изучите все детали дела."
	elif score == 100:
		result = "Отчет идеален. Вы были крайне внимательны и не допустили ни одной ошибки, благодаря чему удалось спасти нескольких участников. Места преступления были почти не тронуты, удалось обнаружить весомые улики, указывающие на организаторов «игр». Можно не сомневаться, что в скором времени они будут пойманы, и это, в первую очередь, Ваша заслуга.\n\nВаши коллеги восхищаются Вами, ведь Вам удалось не только спасти жизни, но и практически полностью раскрыть дело. Руководство довольно Вашими результатами, а потому можете смело ожидать в этом месяце премию.\n\nПоздравляем с проделанной работой!"
	
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


func _on_Credits_tween_completed(object, key):
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
