extends CharacterBody2D

@export var JUMP_VELOCITY = -1500.0;
@export var GRAV_MULT = 3.0;

@onready var Animations = $AnimatedSprite2D

var isSliding = false;
	
func slide(slide):
	if slide == true:
		$SlidingHitBox.disabled = false
		$StandingHitBox.disabled = true
	$SlidingHitBox.disabled = true
	$StandingHitBox.disabled = false



func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta * GRAV_MULT
		Animations.play("jump")
	elif is_on_floor() and not isSliding:
		Animations.play("run")

	# Handle jump
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_released("ui_up") and velocity.y < 0:
		velocity.y *= 0.7
	
	# Handle sliding
	if Input.is_action_pressed("ui_down"):
		Animations.play("slide")
		slide(true)
		GRAV_MULT = 8.0
	elif Input.is_action_just_released("ui_down"):
		GRAV_MULT = 3.0
		slide(false)
		

	move_and_slide()


	
