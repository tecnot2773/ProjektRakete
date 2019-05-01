extends KinematicBody2D

const GRAVITY_VEC = Vector2(0, 700)			# gravitationsvektor
const FLOOR_NORMAL = Vector2(0, -1)			# normal des bodens
var SLOPE_SLIDE_STOP = 0.0				# ?
const MIN_ONAIR_TIME = 0.1					# ?
var WALK_SPEED = 0 							# pixels/sec
const FLY_SPEED = 490						# pixels/sec
const SIDING_CHANGE_SPEED = 10				# ?

export var DRAW_DEBUG = false				# flag ob debug-sachen gezeichnet werden sollen

var linear_vel = Vector2()		# ?
var onair_time = 0				# ?
var on_floor = false			# flag ob auf dem boden
var do_hover = false

var fly_time = 0				# ?
#var energy_regen_timer = 0

var anim=""
var drilling = false

var ray_pos = Vector2(-1, -1)	# ?
var sel_pos = Vector2(-1, -1)	# ?
var end_pos = Vector2(-1, -1)	# ?

var laser_cooldown = 0			# aktuell verbleibende zeit biss der laser wieder einsatzbereit ist

#cache the sprite here for fast access (we will set scale to flip it often)
#onready var sprite = $sprite
onready var playerTex = $playerTex
onready var tilemap = get_node("../TileMap")

#====================================

func updateBoots(mods):
	WALK_SPEED = mods["speed"]
	SLOPE_SLIDE_STOP = float(mods["speed"] / 10.0)
	get_node("../HUD/TextEdit").replaceLine(3, "Speed: " + str(WALK_SPEED))
	pass
#endFUNC

#====================================

# laser upgrades
var laser_cooldown_time=0		# wieviel zeit vergehen muss damit der laser wieder einsatzbereit ist, in sekunden
var laser_max_distance=0		# ?

func updateBohrer(mods):
	laser_cooldown_time = mods["cooldown"]
	laser_max_distance = mods["maxDist"]
	
	get_node("../HUD/TextEdit").replaceLine(1, "Bohrer: maxDist=" + str(laser_max_distance) + "\tcooldown=" + str(laser_cooldown_time))
	
	pass
#endFUNC

#====================================

var ENERGY_PER_SECOND = 8		# energie die per sekunde fliegen verbraucht wird (upgradeable)
var max_fly_time = 1			# ?

func updateJetpack(mods):
	max_fly_time = mods["maxFlyTime"]
	ENERGY_PER_SECOND = mods["eps"]
	
	get_node("../HUD/TextEdit").replaceLine(2, "Jetpack: maxFlyTime=" + str(max_fly_time) + "\teps=" + str(ENERGY_PER_SECOND))
	
	pass
#endFUNC

#====================================

func _calc_endPos():
	var diff = Vector2(0, 0)
	diff.x = get_global_mouse_position().x - self.position.x
	diff.y = get_global_mouse_position().y - self.position.y
	# => differenz zwischen unserem bezugspunkt (self) und dem mauszeiger
			
	if (sqrt(pow(diff.x, 2) + pow(diff.y, 2)) > self.laser_max_distance):
		return false
	
	end_pos = self.position + (diff.normalized() * self.laser_max_distance)
	return true

func _draw():
	var inv = get_global_transform().inverse()
	draw_set_transform(inv.get_origin(), inv.get_rotation(), inv.get_scale())
	
	#var pos = get_global_mouse_position()
	#pos.x = floor(pos.x / 64) * 64
	#pos.y = floor(pos.y / 64) * 64
	#self.draw_rect(Rect2(pos.x, pos.y, 64, 64), Color(1, 0, 0, 1))
	
	#var tilemap = get_node("../TileMap")
	#print(tilemap.world_to_map(sel_pos));
	
	if (sel_pos.x < 0):
		return
	
	self.draw_rect(Rect2(sel_pos.x, sel_pos.y, 64, 64), Color(1, 0, 0, 1), DRAW_DEBUG)
	
	#self.draw_line(self.position, ray_pos, Color(0, 0, 1, 1), 1.0, false)
	
	## debug draw ##
	if (DRAW_DEBUG):
		#self.draw_line(self.position, get_global_mouse_position(), Color(0, 1, 1, 1), 1.0, false)
		self.draw_line(self.position, end_pos, Color(1, 0, 1, 1), 1.0, false)
	
	pass

# tool funktion
static func translate_vec2(v, offset):
	return Vector2(v.x + offset.x, v.y + offset.y)

# setzt die auswahl des cursors zurück
func resetSelector():
	self.sel_pos = Vector2(-1, -1)
	self.ray_pos = Vector2(-1, -1)
	self.end_pos = Vector2(-1, -1)
	pass

# behandelt ob ein block abgebaut werden soll oder nicht sowie setzen des selectors
func handle_destroy_block():
	var isGui = get_node("../Inventar").IsGuiVisble()
	if (isGui):
		return
	#--------------------------------------
	
	var borderID = self.tilemap.getTileSetID("map_border")
	
	var space_state = get_world_2d().direct_space_state;
	
	self.update()
	
	if not _calc_endPos():
		self.resetSelector()
		self.update()
		return
	
	self.update()
	
	#var result = space_state.intersect_ray(self.position, get_global_mouse_position(), [self], tilemap.collision_mask)
	var result = space_state.intersect_ray(self.position, end_pos, [self], self.tilemap.collision_mask)
	if result:
		sel_pos = self.tilemap.map_to_world(result.metadata)
		ray_pos = result.position
	else:
		ray_pos = get_global_mouse_position()
	
	#abbauen
	if (Input.is_action_pressed("abbauen") && not self.sel_pos.x == -1):
		drilling = true
		if laser_cooldown <= 0:
			var mappos = self.tilemap.world_to_map(self.sel_pos)
			var blockID = self.tilemap.get_cellv(mappos);
			if (blockID != -1 && blockID != borderID):
				self.tilemap.set_cellv(mappos, -1);
				#print("destroy: ", blockID, "\t", tilemap.getTileName(blockID))
				var bName = self.tilemap.getTileName(blockID)
				get_node("../Inventar").addItem(bName, 1)
				get_node("../Inventar/CanvasLayer/StatsPan/VBoxContainer").collectItem(bName, 1)
			self.laser_cooldown = laser_cooldown_time
			self.resetSelector()
		#endIF
	else:
		drilling = false
	#endIF
	
	self.update()
	
	pass

#=========================================

func _enter_tree():
	ProjectSettings.set("player", self)
	ProjectSettings.set("endlessJetpack", false)
#endFUNC

func _ready():
	var camera = get_node("camera")
	if (camera.is_current()):
		ProjectSettings.set("currentCamera", camera)
	pass
	
func stepify_vecStr(vec, step):
	return "(" + str(stepify(vec.x, step)) + ", " + str(stepify(vec.y, step)) + ")"

func _physics_process(delta):
	#increment counters

	onair_time += delta
	laser_cooldown -= delta

	if (Input.is_action_just_pressed("screenshot_key")):
		var vport = get_viewport() #get_node('../ViewportScreenShot')
		#vport.world_2d = get_viewport().world_2d
		get_viewport().size = Vector2(2000, 1200);
		get_node("camera").set_zoom(Vector2(10, 10))
		get_node('../HUD').set_scale(Vector2(0, 0))
		#vport.set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")		
		var image = vport.get_texture().get_data()
		image.flip_y()
		var timeDict = OS.get_datetime();
		var fname = "screenshot-%04d-%02d-%02d_%02d-%02d-%02d.png" % [ timeDict["year"], timeDict["month"], timeDict["day"], timeDict["hour"], timeDict["minute"], timeDict["second"] ]
		image.save_png("res://screenshots/" + fname)
		
		get_node('../HUD').set_scale(Vector2(1, 1))
		get_node("camera").set_zoom(Vector2(1, 1))

	### MOVEMENT ###

	# Apply Gravity
	if not self.do_hover:
		linear_vel += delta * GRAVITY_VEC
	
	# Move and Slide
	linear_vel = move_and_slide(linear_vel, FLOOR_NORMAL, SLOPE_SLIDE_STOP)
	
	# move sky
	var sky_pos = 0
	
	if (self.position.y < (39 * 32)):
		#var pos = self.to_global(self.position)
		var pos = self.position
		sky_pos = - (pos.y - (15 * 32))
	else:
		sky_pos = -768
		
	if sky_pos > 0:
		sky_pos = 0
	elif sky_pos < -768:
		sky_pos = -768
	get_node("../parallax_bg").offset.y = sky_pos
	
	get_node("../HUD/TextEdit").replaceLine(0, "Pos: " + str((self.get_global_transform().origin / 64).round()))
	#get_node("../HUD/TextEdit").replaceLine(
	#	0,
	#	"Pos: " +
	#	stepify_vecStr(self.position, 0.01)
	#)
	#et_node("../HUD/TextEdit").replaceLine(4, "Sky.y: " + str(sky_pos))
	
	# Detect Floor
	if is_on_floor():
		onair_time = 0

	on_floor = onair_time < MIN_ONAIR_TIME

	### CONTROL ###
	
	handle_destroy_block()		#TODO maybe move back to _input so we need to click multiple times, and add an upgrade for auto-clicking?
	
	var isNotGui = not get_node("../Inventar").IsGuiVisble()

	# Horizontal Movement
	var target_speed = 0
	if Input.is_action_pressed("move_left") and isNotGui:
		target_speed += -1
	if Input.is_action_pressed("move_right") and isNotGui:
		target_speed +=  1
	
	target_speed *= WALK_SPEED
	linear_vel.x = lerp(linear_vel.x, target_speed, 0.1)
	
	# Fly
	var energy = get_node("../HUD/energyBar")
	var endlessJetpack = ProjectSettings.get("endlessJetpack")
	
	if energy.value > 0 and fly_time < max_fly_time:
		if Input.is_action_pressed("hover") and isNotGui:
			self.do_hover = true
			linear_vel.y = 0
			if not endlessJetpack:
				fly_time += delta
				energy.value -= (delta / max_fly_time * 100)
			#endIF
			
			if Input.is_action_pressed("drop"):
				linear_vel.y = FLY_SPEED
			#endIF
			
		else:
			self.do_hover = false
		#endIF
		
		if Input.is_action_pressed("fly") and isNotGui:
			linear_vel.y = -FLY_SPEED
			if not endlessJetpack:
				fly_time += delta
				energy.value -= (delta / max_fly_time * 100)
		#endIF
	else:
		self.do_hover = false
	#endIF
		
	if Input.is_action_just_released("fly")  and isNotGui:
		fly_time = 0
		
	# energy regeneration
	if energy.value < 100 and fly_time == 0 and on_floor:
		energy.value += ENERGY_PER_SECOND * delta

	### ANIMATION ###

	var new_anim = "idle"

	if on_floor:
		if linear_vel.x < -SIDING_CHANGE_SPEED:
			playerTex.flipX = false
			new_anim = "walking"
			if drilling:
				new_anim = new_anim + "_drilling"

		if linear_vel.x > SIDING_CHANGE_SPEED:
			playerTex.flipX = true
			new_anim = "walking"
			if drilling:
				new_anim = new_anim + "_drilling"
				
		if new_anim == "idle" and drilling:
			new_anim = "drilling"
	else:
		if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right") and isNotGui:
			playerTex.flipX = false
		if Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left")  and isNotGui:
			playerTex.flipX = true

		if linear_vel.y < 0 or do_hover:
			new_anim = "fly"

		#if linear_vel.y < 0:
			#new_anim = "jumping"
		#else:
			#new_anim = "falling"

	if new_anim != anim:
		anim = new_anim
		if new_anim == "fly":
			playerTex.fade_in(anim, -1, -1, 0, "", GDDragonBones.FadeOut_SameLayerAndGroup)
		else:
			playerTex.fade_in(anim, 0.3, -1, 0, "", GDDragonBones.FadeOut_SameLayerAndGroup)
		#$anim.play(anim)
