extends Navigation


func _ready():
	var a = get_node("MeshInstance/NavigationMeshInstance")
	a.enabled = false
	a.enabled = true