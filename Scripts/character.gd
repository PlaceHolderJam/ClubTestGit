extends CharacterBody2D

@export var is_hit = 0;

@onready var JUMP_VELOCITY = -1350.0;
@onready var GRAV_MULT = 2.0;
@onready var Animations = $AnimatedSprite2D
@onready var controller = get_tree().root.get_node("Level1/GameController");

# green tint aae4a0

var isSliding = false;
var was_on_floor = false;
var lowJump = false;

var collision_delay = 0.06
var collision_timer = 0.0
var pending_collision = null
var jump_timer = 0.0
var flash_timer = 0.0

func start_slide():
	$SlidingHitBox.disabled = false
	$StandingHitBox.disabled = true
	
func stop_slide():
	$SlidingHitBox.disabled = true
	$StandingHitBox.disabled = false
	
func handle_jump():
	was_on_floor = false
	jump_timer = 0.0;
			
	if isSliding == true:
		Input.action_release("ui_down")
		Animations.play("jump")
		velocity.y = JUMP_VELOCITY + 150.0
		floor_snap_length = 0.0
	else:
		Animations.play("jump")
		velocity.y = JUMP_VELOCITY
		floor_snap_length = 0.0
		if lowJump == true:
			velocity.y *= .65
			lowJump = false;
	
func _process(delta: float) -> void:
	if not $"I-Frames".is_stopped():
		flash_timer -= delta
		if flash_timer <= 0:
			Animations.visible = not Animations.visible
			flash_timer = .1
	else:
		Animations.visible = true;

func _physics_process(delta: float) -> void:
	if jump_timer > 0:
		jump_timer -= delta;
	
	position.x = 480.0
	
	if not is_on_floor():
		velocity += get_gravity() * delta * GRAV_MULT
		if velocity.y > 200 and Animations.animation != "hurt":
			Animations.play("fall")
			was_on_floor = false;
	elif is_on_floor() and isSliding == false:
		if not was_on_floor: #and Animations.animation != "slide_stand":
			Animations.play("land")
			
			was_on_floor = true;

	if is_on_floor() and jump_timer > 0:
		handle_jump()
	
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		#jumpTimer = jumpBuffer;
		handle_jump()
	elif Input.is_action_just_pressed("ui_up") and was_on_floor:
		handle_jump()
	elif Input.is_action_just_pressed("ui_up") and not is_on_floor():
		jump_timer = 0.15
	
	if Input.is_action_just_released("ui_up") and velocity.y < 0:
		velocity.y *= .65
	elif Input.is_action_just_released("ui_up") and jump_timer > 0:
		lowJump = true;
	
	if Input.is_action_just_pressed("ui_down") and is_on_floor():
		Animations.play("slide")
		isSliding = true
		start_slide()
		
	if Input.is_action_pressed("ui_down") and is_on_floor():
		if not was_on_floor:
			Animations.play("dive_slide")
			was_on_floor = true;
		
	elif Input.is_action_pressed("ui_down") and not is_on_floor():
		Animations.play("dive")
		was_on_floor = false;
		isSliding = true
		start_slide()
		GRAV_MULT = 8.5
		
	if Input.is_action_just_released("ui_down"):
		isSliding = false
		
		if not is_on_floor():
			if velocity.y > 0:
				Animations.play("fall")
			else:
				Animations.play("jump")
		else:
			Animations.play("slide_stand")
		
		GRAV_MULT = 2.0
		stop_slide()
		
	if is_on_floor():
		floor_snap_length = 5.0
	else:
		floor_snap_length = 0.0
	
	move_and_slide()
	
	var hit_obstacle = false
	var collider = null
	var normal = null
	
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		collider = collision.get_collider()
		normal = collision.get_normal()
		
		
		if collider and collider.is_in_group("obstacle"):
			if abs(normal.x) > 0.7:
		
				#print_debug("Collision:", i, "Node:", collider, "Normal:", normal)
				
				hit_obstacle = true
				collision_delay = .06
				break
			elif normal.y > 0.7:
				
				#print_debug("Collision:", i, "Node:", collider, "Normal:", normal)
				
				if not collider.topCollidable:
					hit_obstacle = true
					collision_delay = 0.01
					break
			
	if hit_obstacle:
		if pending_collision == collider:
			collision_timer -= delta
			if collision_timer <= 0:
				_disable_obstacle_collision(collider)
				pending_collision = null
				
				if $"I-Frames".is_stopped():
					Animations.play("hurt")
					handleHit()
				
				print_debug("Obstacle was hit!")
		else:
			pending_collision = collider
			collision_timer = collision_delay
	else:
		pending_collision = null
		collision_delay = .06
			

func handleHit():
	if is_hit == 0:
		controller.SPEED -= 400
		is_hit = 1;
		$hitTimer.start()
		$Troubled.visible = true
		$Troubled.play("default")
		$"I-Frames".start()
		
		if isSliding:
			Input.action_release("ui_down")
		
	elif is_hit == 1:
		get_tree().quit()
		

func _disable_obstacle_collision(collider):
	for shape in collider.get_children():
		if shape is CollisionShape2D:
			shape.set_deferred("disabled", true)
		if shape is Sprite2D:
			shape.z_index = 0

func _on_animated_sprite_2d_animation_finished() -> void:
	if Animations.animation == "land":
		Animations.play("run")
	elif Animations.animation == "slide_stand":
		Animations.play("run")
	elif Animations.animation == "hurt":
		Animations.play("run")
			


func _on_timer_timeout() -> void:
	is_hit = 0;
	$Troubled.visible = false
