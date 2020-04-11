extends Spatial

#load scenes
var player = preload("res://Player.tscn")
var resource_node = preload("res://ResourceNode.tscn")
var worker = preload("res://Worker.tscn")
var ground = preload("res://Floor.tscn")
var resources = []
const BOUNDARY = 500

#instantiate scenes
func _ready():
	var ground_instance = ground.instance()
	add_child(ground_instance)
	var player_instance = player.instance()
	add_child(player_instance)
	for i in range(3):
		var worker_instance = worker.instance()
		add_child(worker_instance)
		worker_instance.translation = Vector3(i*5, worker_instance.translation.y, i*5)
	var rng = RandomNumberGenerator.new()
	for _i in range(50):
		randomize()
		var resource_instance = resource_node.instance()
		add_child(resource_instance)
		resources.append(resource_instance)
		var x = rng.randi_range(-BOUNDARY, BOUNDARY)
		var z = rng.randi_range(-BOUNDARY, BOUNDARY)
		resource_instance.translate(Vector3(x, 0, z))

