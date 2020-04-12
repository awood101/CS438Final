extends KinematicBody

onready var player_node = get_node('../Player')
onready var nav_node = get_node('../Floor')
onready var main_node = get_node('..')
onready var stone_node = get_node('../Control/StoneCount')
var group = 'player'
var nav_path = []
var cur_nav_path_index = 0
var floor_normal = Vector3(0, 1, 0)
var counter = 0
const SPEED = 15

func _ready():
	player_node.connect("check_unit_pos", self, '_on_check_unit_pos')
	player_node.connect("move_units", self, '_on_move_units')
	
	
func _on_check_unit_pos(box):
	if box.has_point(player_node.cam.unproject_position(self.global_transform.origin)):
		if self in player_node.selected:
			pass
		else:
			player_node.selected.append(self)
			$SelectionRing.visible = true
			
func _on_move_units(raycast):
	if self in player_node.selected:
		if raycast:
			nav_path = nav_node.get_simple_path(self.global_transform.origin, raycast.position)
			cur_nav_path_index = 0
			
func _physics_process(delta):
	#check if currently on path
	if cur_nav_path_index < nav_path.size():
		#get movement vector from current global position pointing towards current destination
		var cur_move = (nav_path[cur_nav_path_index] - global_transform.origin + Vector3(0, 1, 0))
		print(nav_path)
		if $RayCastPosX.get_collider():
			cur_move = cur_move - $RayCastPosX.cast_to
		if $RayCastNegX.get_collider():
			cur_move = cur_move - $RayCastNegX.cast_to
		if $RayCastPosY.get_collider():
			cur_move = cur_move - $RayCastPosY.cast_to
		if $RayCastNegY.get_collider():
			cur_move = cur_move - $RayCastNegY.cast_to
		if cur_move.length() < 1:
			cur_nav_path_index += 1
		else:
			move_and_slide(cur_move.normalized() * SPEED, Vector3(0, 1, 0))
	for i in main_node.resources:
		if global_transform.origin.distance_to(i.global_transform.origin) < 5:
			if counter >= 1 / delta:
				counter = 0
				stone_node.increment_resource()
			counter += 1