extends TileMap

var layers = [
	{ "rows": 1 , "tileID": 3 },	#border top
	{ "rows": 4 , "tileID": -1 },	#air
	{ "rows": 1 , "tileID": 0 },	#grass
	{ "rows": 20, "tileID": 1 },	#erde
	{ "rows": 1 , "tileID": 3 }		#border bottom
]

const OFFSET_Y = -1;
const MAX_X = 20
const MAX_Y = 100

func generateMap():
	self.clear()
	#var HUD_label = get_node("../HUD/Label")
	
	var y = 0
	
	for layer in layers:
		if (not layer["tileID"] == -1):
			for r in range(layer["rows"]):
				for x in range(MAX_X):
					set_cell(x, (y + r + OFFSET_Y), layer["tileID"])
		y += layer["rows"]
	
	#generate alphawand
	#left | right
	for y in range(MAX_Y):
		set_cell(-1, y, 3)
		set_cell(MAX_X, y, 3)
		
	pass

func _ready():
	generateMap()
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
