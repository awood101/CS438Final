extends Control

var initial_mouse_select
var cur_mouse_select
const COLOR = Color(0.69, 0.77, 0.87, 1)
const WIDTH = 3

func _draw():
	if visible:
		draw_line(initial_mouse_select, Vector2(initial_mouse_select.x, cur_mouse_select.y), COLOR, WIDTH)
		draw_line(initial_mouse_select, Vector2(cur_mouse_select.x, initial_mouse_select.y), COLOR, WIDTH)
		draw_line(cur_mouse_select, Vector2(initial_mouse_select.x, cur_mouse_select.y), COLOR, WIDTH)
		draw_line(cur_mouse_select, Vector2(cur_mouse_select.x, initial_mouse_select.y), COLOR, WIDTH)
	
func _process(_delta):
	update()