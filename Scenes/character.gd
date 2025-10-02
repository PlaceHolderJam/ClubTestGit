extends CharacterBody2D

@export var JUMP_VELOCITY = -1500.0;
@export var GRAV_MULT = 3.0;

@onready var Animations = $AnimatedSprite2D

var isSliding = false;

func start_slide():
	$SlidingHitBox.disabled = false
	$StandingHitBox.disabled = true
	
func stop_slide():
	$SlidingHitBox.disabled = true
	$StandingHitBox.disabled = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * GRAV_MULT
		Animations.play("jump")
	elif is_on_floor() and isSliding == false:
		Animations.play("run")

	# Handle jump.
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	if Input.is_action_just_released("ui_up") and velocity.y < 0:
		velocity.y *= .7
	
	if Input.is_action_pressed("ui_down") and is_on_floor():
		Animations.play("slide")
		isSliding = true
		start_slide()
		
	elif Input.is_action_pressed("ui_down") and not is_on_floor():
		Animations.play("slide")
		isSliding = true
		start_slide()
		GRAV_MULT = 8.0
		
	if Input.is_action_just_released("ui_down"):
		isSliding = false
		GRAV_MULT = 3.0
		stop_slide()
	

	move_and_slide()
