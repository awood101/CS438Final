extends Label
var inside = false
signal clicked_on

func _on_BuildSpriteArea_mouse_entered():
	inside = true
	
func _on_BuildSpriteArea_mouse_exited():
	inside = false

func _input(event):	
	if inside == true:
		if Input.is_action_just_pressed("ui_left_click"):
			emit_signal("clicked_on")