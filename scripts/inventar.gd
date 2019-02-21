extends CanvasLayer

#func toggleView():
#	var invNode = get_tree().get_root().get_node("stage/Inventar")
#	invNode.visible = not invNode.visible

func _ready():
	self.set_scale(Vector2(0, 0))
	self.set_process(true)

func _process(delta):
	
	if (Input.is_action_just_pressed("show_inventar")):
		if self.scale.x == 0:
			self.set_scale(Vector2(1, 1))
		else:
			self.set_scale(Vector2(0, 0))
	
