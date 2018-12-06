extends KinematicBody2D

const GRAVITY_VEC = Vector2(0, 700)
const FLOOR_NORMAL = Vector2(0, -1)
const SLOPE_SLIDE_STOP = 25.0
const MIN_ONAIR_TIME = 0.1
const WALK_SPEED = 250 # pixels/sec
const FLY_SPEED = 480
const SIDING_CHANGE_SPEED = 10
const ENERGY_PER_SECOND = 8

var linear_vel = Vector2()
var onair_time = 0
var on_floor = false

var max_fly_time = 1
var fly_time = 0
#var energy_regen_timer = 0

var anim=""

#cache the sprite here for fast access (we will set scale to flip it often)
onready var sprite = $sprite

func _physics_process(delta):
	#increment counters

	onair_time += delta

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
	
	if energy.value > 0 and fly_time < max_fly_time and Input.is_action_pressed("fly"):
		linear_vel.y = -FLY_SPEED
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
			sprite.scale.x = -1
			new_anim = "run"

		if linear_vel.x > SIDING_CHANGE_SPEED:
			sprite.scale.x = 1
			new_anim = "run"
	else:
		if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
			sprite.scale.x = -1
		if Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
			sprite.scale.x = 1

		if linear_vel.y < 0:
			new_anim = "jumping"
		else:
			new_anim = "falling"

	if new_anim != anim:
		anim = new_anim
		$anim.play(anim)
