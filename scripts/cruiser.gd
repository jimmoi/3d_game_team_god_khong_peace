extends CharacterBody3D

# How fast the player moves in meters per second.
@export var speed = 14
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 75
@export var movable_distance = 200

var target_velocity = Vector3.ZERO
var on_use = false
var player_i

var hp = 20
signal die_signal

# Renamed cam to camera_node for clarity
@onready var camera_node: Camera3D = $SpringArm3D/camera
@onready var collistion_node: CollisionShape3D = $hitbox
@onready var area_node = $Area3D
# Assuming you have a Camera3D node nested under the SpringArm3D

# Note: The original 'cam' variable and '_ready()' are replaced by @onready 
# to ensure the node path is correct and accessible immediately.

func _physics_process(delta):
	if on_use:
		# 1. Get the raw input direction (still relative to the player's local axes)
		var input_direction = Vector3.ZERO

		if Input.is_action_pressed("right"):
			input_direction.x += 1
		if Input.is_action_pressed("left"):
			input_direction.x -= 1
		if Input.is_action_pressed("down"):
			input_direction.z += 1
		if Input.is_action_pressed("up"):
			input_direction.z -= 1
		
		# 2. Start movement logic only if there's input
		if input_direction != Vector3.ZERO:
			# Normalize the input vector to prevent faster diagonal movement
			input_direction = input_direction.normalized()
			
			# === CORE CHANGE: Transform the input to be relative to the camera ===
			
			# Get the camera's Y-axis (horizontal) rotation only. 
			# This ensures the character doesn't fly up/down when looking up/down.
			var camera_basis = camera_node.global_transform.basis
			
			# Project the camera's X and Z axes onto the flat XZ plane (Y=0)
			# to get vectors for 'right' and 'forward' movement on the ground.
			var right_vector = camera_basis.x.normalized()
			var forward_vector = camera_basis.z.normalized()
			
			# Calculate the final world-space direction vector:
			# forward (Z) input * camera's forward + right (X) input * camera's right
			var world_direction = (forward_vector * input_direction.z) + (right_vector * input_direction.x)
			
			# Ensure the vector is normalized and flat
			world_direction.y = 0 
			world_direction = world_direction.normalized()
			
			# Set Model Rotation (Facing Direction)
			# Look at the calculated world_direction vector.
			# Using `global_transform` ensures the rotation is calculated from the world origin.
			$model.global_transform = $model.global_transform.looking_at(
				global_transform.origin + world_direction, 
				Vector3.UP # Up direction is always World Up
			)
			
			collistion_node.rotation = $model.rotation 
			area_node.rotation = $model.rotation 
			
			# Ground Velocity (Movement)
			target_velocity.x = world_direction.x * speed
			target_velocity.z = world_direction.z * speed

		else:
			# Stop movement quickly when input is released (deceleration)
			target_velocity.x = lerp(target_velocity.x, 0.0, 0.1) 
			target_velocity.z = lerp(target_velocity.z, 0.0, 0.1)

		# Vertical Velocity (Gravity)
		if not is_on_floor(): 
			target_velocity.y -= fall_acceleration * delta
		
		# Moving the Character
		velocity = target_velocity
		move_and_slide()
		
func apply_damage() -> void:
	hp -= Manager.damage_per_round
	if hp==0:
		die_signal.emit(self)
		
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("bullet"):
		apply_damage()
