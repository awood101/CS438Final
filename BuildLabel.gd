extends Label
var counter = 0

func _on_BuildLabel_mouse_entered():
	counter += 1
	print(counter)
