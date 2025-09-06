extends TextureRect

var pressCount: int = 0


func _on_button_pressed() -> void:
	pressCount += 1
	if pressCount >= 10:
		$Button.disabled = true
		var startpos = $textbox.position
		$textbox.show()
		await get_tree().create_timer(3).timeout
		$"textbox/Panel/1".hide()
		$"textbox/Panel/2".show()
		var tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		@warning_ignore("integer_division")
		var top = (DisplayServer.window_get_size()[1]/2)/1.5
		tween.tween_property($textbox, "position", $textbox.position - Vector2(0,top), 1.5)
		await get_tree().create_timer(3).timeout
		$"textbox/Panel/2".hide()
		$"textbox/Panel/3".show()
		await get_tree().create_timer(3).timeout
		$lightmode.show()
		await get_tree().create_timer(5).timeout
		$textbox.position = startpos
		$"textbox/Panel/3".hide()
		$"textbox/Panel/4".show()
		tween = get_tree().create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property($lightmode, "modulate", Color(1,1,1,0), 5)
		await get_tree().create_timer(5).timeout
		$lightmode.hide()
		$lightmode.modulate = Color(1,1,1,1)
		await get_tree().create_timer(3).timeout
		$textbox.hide()
		$"textbox/Panel/4".hide()
		$"textbox/Panel/1".show()

		$Button.disabled = false
		pressCount = 0
