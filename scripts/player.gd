extends KinematicBody2D

const GRAVITY_VEC = Vector2(0, 700)
const FLOOR_NORMAL = Vector2(0, -1)
const SLOPE_SLIDE_STOP = 25.0
const MIN_ONAIR_TIME = 0.1
const WALK_SPEED = 250 # pixels/sec
const FLY_SPEED = 480
const SIDING_CHANGE_SPEED = 10
const ENERGY_PER_SECOND = 8

const BARRIER_ID = 3

const DRAW_DEBUG = false

var linear_vel = Vector2()
var onair_time = 0
var on_floor = false

var max_fly_time = 1
var fly_time = 0
#var energy_regen_timer = 0

var anim=""

var ray_pos = Vector2(-1, -1)
var sel_pos = Vector2(-1, -1)
var end_pos = Vector2(-1, -1)

var laser_max_distance = 300
var laser_cooldown = 0

#cache the sprite here for fast access (we will set scale to flip it often)
#onready var sprite = $sprite
onready var playerTex = $playerTex

func _calc_endPos():
	var diff = Vector2(0, 0)
	diff.x = get_global_mouse_position().x - self.position.x
	diff.y = get_global_mouse_position().y - self.position.y
	
	var diff2 = Vector2(0, 0)
	if (not diff.x == 0):
		diff2.y = (diff.y / abs(diff.x))
		if (diff.x < 0):
			diff2.x = -1
		else:
			diff2.x = 1
			
	#print(diff, "|", diff2, "|", (diff2 * 10))
	end_pos = self.position + (diff2 * 2000)
	pass

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
		self.draw_line(self.position, get_global_mouse_position(), Color(0, 1, 1, 1), 1.0, false)
		self.draw_line(self.position, end_pos, Color(1, 0, 1, 1), 1.0, false)
	
	pass

static func translate_vec2(v, offset):
	return Vector2(v.x + offset.x, v.y + offset.y)

func resetSelector():
	self.sel_pos = Vector2(-1, -1)
	self.ray_pos = Vector2(-1, -1)
	self.end_pos = Vector2(-1, -1)
	pass

func handle_destroy_block():
	var tilemap = get_node("../TileMap")
	
	var space_state = get_world_2d().direct_space_state;
	
	var diff = Vector2(0, 0)
	diff.x = get_global_mouse_position().x - self.position.x
	diff.y = get_global_mouse_position().y - self.position.y
	if (sqrt(pow(diff.x, 2) + pow(diff.y, 2)) > self.laser_max_distance):
		self.resetSelector()
		self.update()
		return
	
	_calc_endPos()
	
	#var result = space_state.intersect_ray(self.position, get_global_mouse_position(), [self], tilemap.collision_mask)
	var result = space_state.intersect_ray(self.position, end_pos, [self], tilemap.collision_mask)
	if result:
		sel_pos = tilemap.map_to_world(result.metadata)
		ray_pos = result.position
	else:
		ray_pos = get_global_mouse_position()
	
	#abbauen
	if (Input.is_action_pressed("abbauen") && not self.sel_pos.x == -1 && laser_cooldown <= 0):
		var mappos = tilemap.world_to_map(self.sel_pos)
		var blockID = tilemap.get_cellv(mappos);
		if (blockID != -1 && blockID != BARRIER_ID):
			tilemap.set_cellv(mappos, -1);
		laser_cooldown = 0.3	#TODO make this a variable so we can upgrade this
		pass
	
	self.update()
	
	pass

func _ready():
	var camera = get_node("camera")
	if (camera.is_current()):
		ProjectSettings.set("currentCamera", camera)
	pass

func _physics_process(delta):
	#increment counters

	onair_time += delta
	
	laser_cooldown -= delta
	handle_destroy_block()		#TODO maybe move back to _input so we need to click multiple times, and add an upgrade for auto-clicking?

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
	linear_vel += delta * GRAVITY_VEC
	# Move and Slide
	linear_vel = move_and_slide(linear_vel, FLOOR_NORMAL, SLOPE_SLIDE_STOP)
	# Detect Floor
	if is_on_floor():
		onair_time = 0

	on_floor = onair_time < MIN_ONAIR_TIME

	### CONTROL ###

	# Horizontal Movement
	var target_speed = 0
	if Input.is_action_pressed("move_left"):
		target_speed += -1
	if Input.is_action_pressed("move_right"):
		target_speed +=  1
	
	target_speed *= WALK_SPEED
	linear_vel.x = lerp(linear_vel.x, target_speed, 0.1)
	
	# Fly
	var energy = get_node("../HUD/energyBar")
	
	if energy.value > 0 and fly_time < max_fly_time:
		if Input.is_action_pressed("fly"):
			linear_vel.y = -FLY_SPEED
			if not Input.is_action_pressed("endless_jetpack"):	#Ü
				fly_time += delta
				energy.value -= (delta / max_fly_time * 100)
		
		if Input.is_action_pressed("hover"):
			linear_vel -= delta * GRAVITY_VEC
			#linear_vel.y = -(delta * GRAVITY_VEC)
			if not Input.is_action_pressed("endless_jetpack"):	#Ü
				fly_time += delta
				energy.value -= (delta / max_fly_time * 100)
		
	if Input.is_action_just_released("fly"):
		fly_time = 0
		
	# energy regeneration
	if energy.value < 100 and fly_time == 0 and on_floor:
		energy.value += ENERGY_PER_SECOND * delta

	### ANIMATION ###

	get_node("../HUD/Label").text = "Pos: " + str((self.get_global_transform().origin / 64).round())

	var new_anim = "idle"

	if on_floor:
		if linear_vel.x < -SIDING_CHANGE_SPEED:
			#sprite.scale.x = -1
			playerTex.flipX = false
			new_anim = "walking"

		if linear_vel.x > SIDING_CHANGE_SPEED:
			#sprite.scale.x = 1
			playerTex.flipX = true
			new_anim = "walking"
	else:
		if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
			#sprite.scale.x = -1
			playerTex.flipX = false
		if Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
			#sprite.scale.x = 1
			playerTex.flipX = true

		#if linear_vel.y < 0:
			#new_anim = "jumping"
		#else:
			#new_anim = "falling"

	if new_anim != anim:
		anim = new_anim
		playerTex.fade_in(anim, 0.3, -1, 0, "", GDDragonBones.FadeOut_SameLayerAndGroup)
		#$anim.play(anim)
