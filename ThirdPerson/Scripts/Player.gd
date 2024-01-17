extends CharacterBody3D

@onready var camera_mount = $camera_mount
@onready var animation_player = $visuals/Ybot_BasicMovement/AnimationPlayer
@onready var visuals = $visuals

var SPEED = 3.0
var walk_speed = 3.0
var run_speed = 5.0
var running = false
var locked = false

const JUMP_VELOCITY = 4.5

@export var sens_h = 0.2
@export var sens_v = 0.2

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED #Capture the mouse in the window so it doesnt show on the screen

func _input(event): #Check for input events
	if event is InputEventMouseMotion: #Check if the inputevent is a mousemotion
		rotate_y(deg_to_rad(-event.relative.x) * sens_h) #Rotate the Player relative to the MouseMotion Xaxis times the horizontal sensitivity
		visuals.rotate_y(deg_to_rad(event.relative.x) * sens_h) #Rotate the visuals inverted relative to the mousemostion
		camera_mount.rotate_x(deg_to_rad(-event.relative.y) * sens_v) #Rotate the camera_mount relative to the MouseMotion Yaxis times the vertical sensitivity

func _physics_process(delta):
	if !animation_player.is_playing():
		locked = false
	if Input.is_action_just_pressed("Kick"):
		animation_player.play("Kick")
		locked = true
		
	if Input.is_action_pressed("run"):
		SPEED = run_speed
		running = true
	else:
		SPEED = walk_speed
		running = false
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backwards")
	var current_position = position
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var new_position = position - direction
	if !locked:
		if direction: #Check if the player is moving
			if running:
				if animation_player.current_animation != "Running": #If the player is moving and the walk animation is NOT playing. PLay the walk animation
					animation_player.play("Running")
			else:
				if animation_player.current_animation != "Walking": #If the player is moving and the walk animation is NOT playing. PLay the walk animation
					animation_player.play("Walking")
			
			#visuals.look_at(position - direction)
			print(get_position_delta())
			#visuals.rotation.y = lerp(visuals.rotation.y, atan2((current_position.x - new_position.x), (current_position.z - new_position.z)), 1) - rotation.y
			visuals.rotation.y = lerp(visuals.rotation.y, atan2((current_position.x - new_position.x), (current_position.z - new_position.z)), 1) - rotation.y
			print("Visuals rotation: " + str(visuals.rotation.y) + " Player Rotation: " + str(rotation.y))
			print(current_position)
			print(new_position)
			
			#FIXME var new_transform = visuals.transform.looking_at(direction + position, Vector3.UP)
			#FIXME visuals.transform = visuals.transform.interpolate_with(new_transform, 1)
			
			
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			if animation_player.current_animation != "Idle": #If the player is NOT moving and the Idle animation is NOT playing. PLay the Idle animation
				animation_player.play("Idle")
			
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
			
		move_and_slide()
