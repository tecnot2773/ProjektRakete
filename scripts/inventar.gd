extends ItemList

#func toggleView():
#	var invNode = get_tree().get_root().get_node("stage/Inventar")
#	invNode.visible = not invNode.visible

onready var canvas = get_node("../../")

func _ready():
	canvas.set_scale(Vector2(0, 0))
	self.set_process(true)

func _process(delta):
	
	if (Input.is_action_just_pressed("show_inventar")):
		if canvas.scale.x == 0:
			canvas.set_scale(Vector2(1, 1))
		else:
			canvas.set_scale(Vector2(0, 0))
	
