extends KinematicBody

export var acceleration = 100
export var friction = 0.85
export var gravity = 80
export var jump_power = 30
export var mouse_sensitivity = 1.5

onready var HeadNode = $Head
onready var CameraNode = $Head/Camera

var vel = Vector3()
var mouse_pos_change = Vector2()

func _ready():
	# Capture mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# Save mouse movement to the variable which will be used in aim()
	if event is InputEventMouseMotion:
		mouse_pos_change = event.relative
	# Release the mouse when ESC
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	aim()
	walk(delta)
	jump()
	vel = move_and_slide(vel, Vector3.UP, true, 4)

func aim():
	if not mouse_pos_change.length(): return # if mouse was moved and camera needs to turn
	# Rotate horizontally
	HeadNode.rotate_y(deg2rad(-mouse_pos_change.x * mouse_sensitivity))
	# Rotate vertically
	CameraNode.rotate_x(deg2rad(-mouse_pos_change.y * mouse_sensitivity))
	# Limit rotation to 90 degrees
	CameraNode.rotation.x = clamp(CameraNode.rotation.x,-deg2rad(60), deg2rad(60))
	# Reset camera change after it has been performed
	mouse_pos_change = Vector2()

func walk(delta):
	# Basis contains 3 vectors, each vector points in the direction its axis has been rotated,
	# so they effectively describe the node's total rotation
	var head_rotation = CameraNode.get_global_transform().basis
	
	var move_direction = Vector3()
	# Direction vector based on where head is pointing at
	if Input.is_action_pressed("move_forward"):
		# Forward direction in Godot is -z. So I move forward in the direction where head is pointing at
		move_direction -= head_rotation.z
	elif Input.is_action_pressed("move_backward"):
		move_direction += head_rotation.z
	if Input.is_action_pressed("move_left"):
		move_direction -= head_rotation.x
	elif Input.is_action_pressed("move_right"):
		move_direction += head_rotation.x
	move_direction = move_direction.normalized()
	
	# Acceleration
	vel += move_direction * acceleration * delta
	
	# Friction
	vel *= friction
	
	# Gravity
	vel.y -= gravity * delta

func jump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		vel.y += jump_power
