extends Spatial

var vector = Vector3()
var cam
var select_box
var ground
var cur_mouse_pos = Vector3()
var drag_mouse_pos  = Vector3()
var old_drag_mouse_pos  = Vector3()
var rotating = false
var drag_selecting = false
var initial_mouse_select  = Vector3()
var cur_mouse_select  = Vector3()
var selected = []
signal check_unit_pos
signal move_units
const building = preload("res://Building.tscn")
const SHIFT_KEY = 16777237
const RAY_LENGTH = 1000
const DEFAULT_ZOOM = Vector3(0, 27.7, 11.28)
const ZOOM_VECTOR = Vector3(0, 0.75, 0)
const PLAYER_SPEED = 1
const PLAYER_ROTATION_SPEED = 0.03 #radians

func _ready():
	cam = get_node("Camera")
	select_box = get_node("SelectBox")
	ground = get_node("../Floor")
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	
#from godot raycast tutorial
#gets 3D position of mouse in world
func mouse_raycast(layer):
	var from = cam.project_ray_origin(cur_mouse_pos)
	var to = from + cam.project_ray_normal(cur_mouse_pos) * RAY_LENGTH
	var state = get_world().direct_space_state
	return state.intersect_ray(from, to, [], layer)

#selecting single unit from left mouse click
#key: shift
func get_single_unit():
	#checking for ray collision in unit layer
	var cur_selection = mouse_raycast(2)
	#checking that unit was found
	if cur_selection.size() > 0:
		#checking that unit belongs to player
		if cur_selection.collider.group == 'player':
			#check if unit is already selected
			if cur_selection.collider in selected:
				#remove if shift is held and at least 1 other unit is selected
				if Input.is_key_pressed(SHIFT_KEY) == true:
					if selected.size() > 1:
						cur_selection.collider.get_node("SelectionRing").visible = false
						selected.remove(selected.find(cur_selection.collider))
				#if shift is not held then remove all other units from selection
				else:
					for i in selected:
						i.get_node("SelectionRing").visible = false
					selected.clear()
					cur_selection.collider.get_node("SelectionRing").visible = true
					selected.append(cur_selection.collider)
			else:
				#clear selected units if shift not pressed down
				if Input.is_key_pressed(SHIFT_KEY) == false:
					for i in selected:
						i.get_node("SelectionRing").visible = false
					selected.clear()
				cur_selection.collider.get_node("SelectionRing").visible = true
				selected.append(cur_selection.collider)
	#clear selection if nothing clicked on and shift is not pressed down
	elif Input.is_key_pressed(SHIFT_KEY) == false:
		for i in selected:
			i.get_node("SelectionRing").visible = false
		selected.clear()

#selecting potentially multiple units from inside selection box
func get_multiple_units():
	if Input.is_key_pressed(SHIFT_KEY) == false:
		for i in selected:
			i.get_node("SelectionRing").visible = false
		selected.clear()
	var low_x = min(initial_mouse_select.x, cur_mouse_select.x)
	var low_y = min(initial_mouse_select.y, cur_mouse_select.y)
	var high_x = max(initial_mouse_select.x, cur_mouse_select.x)
	var high_y = max(initial_mouse_select.y, cur_mouse_select.y)
	var box = Rect2(Vector2(low_x, low_y), Vector2(high_x - low_x, high_y - low_y))
	emit_signal('check_unit_pos', box)
	
#allows selection box to be drawn on screen
func draw_selection_box():
	select_box.initial_mouse_select = initial_mouse_select
	select_box.cur_mouse_select = cur_mouse_select
	select_box.visible = true
	
func get_menu_button_clicked():
	pass

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			#zoom in
			#mouse wheel scroll up
			if event.button_index == BUTTON_WHEEL_UP:
				cam.set_translation(cam.get_translation() - ZOOM_VECTOR)
			#zoom out
			#mouse wheel scroll down
			if event.button_index == BUTTON_WHEEL_DOWN:
				cam.set_translation(cam.get_translation() + ZOOM_VECTOR)
			#right click
			if event.button_index == BUTTON_RIGHT:
				emit_signal('move_units', mouse_raycast(1))
			
	elif event is InputEventKey:
		#reset rotation and zoom
		#key: home
		if event.scancode == KEY_HOME:
			set_rotation_degrees(Vector3(0, 0, 0))
			cam.set_translation(DEFAULT_ZOOM)

func _process(delta):
	cur_mouse_pos = get_viewport().get_mouse_position()
	vector.x = 0
	vector.y = 0
	vector.z = 0
	#key: w
	if Input.is_action_pressed("ui_up"):
		translate(Vector3(0, 0, 0 - PLAYER_SPEED))
	#key: s
	if Input.is_action_pressed("ui_down"):
		translate(Vector3(0, 0, PLAYER_SPEED))
	#key: d
	if Input.is_action_pressed("ui_right"):
		translate(Vector3(PLAYER_SPEED, 0, 0))
	#key: a
	if Input.is_action_pressed("ui_left"):
		translate(Vector3(0 - PLAYER_SPEED, 0, 0))
	#drag with middle mouse
	if Input.is_action_pressed("ui_drag"):
		if rotating == false:
			drag_mouse_pos = get_viewport().get_mouse_position() - old_drag_mouse_pos
			translate((Vector3(0, 0, 0) - Vector3(drag_mouse_pos.x, 0, drag_mouse_pos.y)) * 8 * delta)
	old_drag_mouse_pos = get_viewport().get_mouse_position()
	#key: q
	if Input.is_action_pressed("ui_rotate_ccw"):
		rotate_y(PLAYER_ROTATION_SPEED)
	#key: e
	if Input.is_action_pressed("ui_rotate_cw"):
		rotate_y(-PLAYER_ROTATION_SPEED)
		
	#left mouse button
	if Input.is_action_just_pressed("ui_left_click"):
		initial_mouse_select = get_viewport().get_mouse_position()
	elif Input.is_action_pressed("ui_left_click"):
		cur_mouse_select = get_viewport().get_mouse_position()
		if cur_mouse_select.distance_to(initial_mouse_select) > 20:
			drag_selecting = true
			draw_selection_box()	
	elif Input.is_action_just_released("ui_left_click"):
		if drag_selecting == false:
			get_single_unit()
		elif drag_selecting == true:
			drag_selecting = false
			select_box.visible = false
			get_multiple_units()

func _on_BuildSpriteArea_clicked_on():
	var cur_building = building.instance()
	var parent_node = get_parent()
	parent_node.add_child(cur_building)
	cur_building.translate(Vector3(-5, 1, 0))
