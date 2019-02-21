extends TileMap

var dirtID = self.get_tileset().find_tile_by_name("dirt")
var borderID = self.get_tileset().find_tile_by_name("map_border")
var grassID = self.get_tileset().find_tile_by_name("grassblock")
var stoneID = self.get_tileset().find_tile_by_name("steinblock")

func getTileSetID(name):
	return self.get_tileset().find_tile_by_name(name)

func genGrassLayer(_seed):
	var valueNoise1D = load('res://scripts/valuenoise1D.gd').new(_seed + randi())
	for i in range(MAX_X):
		var t = valueNoise1D.eval(i * 0.2);
		var y = round(t * 10)
		for j in range(y):
			set_cell(i, (j * -1) + 13, dirtID)
		set_cell(i, (y * -1) + 13, grassID)
		
func genStoneLayer(_seed):
	var valueNoise1D = load('res://scripts/valuenoise1D.gd').new(_seed + randi())
	for i in range(MAX_X):
		var t = valueNoise1D.eval(i * 0.2)
		var y = round(t * 8)
		for j in range(y):
			set_cell(i, (j * -1) + 20, stoneID)		#insert Stone id here

func genErze(_seed):
	
	pass

var layers = [
	{ "rows":  1, "tileID":  borderID },	#border top
	{ "rows": 14, "tileID": -1 },	#air
	{ "rows":  2, "tileID":  dirtID },	#erde
	{ "rows": 90, "tileID":  stoneID },
	{ "rows":  1, "tileID":  borderID }	#border bottom
]

const OFFSET_Y = -1;
const MAX_X = 400
const MAX_Y = 100

func generateMap():
	self.clear()
	#var HUD_label = get_node("../HUD/Label")
	
	var y = 0
	
	for layer in layers:
		if (not layer["tileID"] == -1):
			for r in range(layer["rows"]):
				for x in range(MAX_X):
					#map.set_cell(x, (y + r + OFFSET_Y), layer["tileID"])
					set_cell(x, (y + r + OFFSET_Y), layer["tileID"])
		y += layer["rows"]
		
	randomize()
	var _seed = randi()
	genGrassLayer(_seed)
	genStoneLayer(_seed)
	genErze(_seed)
	
	#generate alphawand
	#left | right
	for y in range(MAX_Y):
		set_cell(-1, y, borderID)
		set_cell(MAX_X, y, borderID)
		
	pass

func _ready():
	generateMap()
	pass
