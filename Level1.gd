extends Node2D

# Scene reference
var ObstacleScene: PackedScene = preload("res://Scenes/obstacle.tscn")

# Base parameters (starting values)
@export var starting_gap_size: int = 260
@export var starting_spawn_interval: float = 2.6
@export var starting_speed: float = 350.0

# Scaling rates (how fast difficulty increases)
@export var speed_increase_rate: float = 10.0        # pixels per second^2
@export var spawn_interval_decay: float = 0.015       # seconds per second
@export var gap_shrink_rate: float = 5.0              # pixels per second

# Limits (maximum difficulty)
@export var min_gap_size: int = 140
@export var min_spawn_interval: float = 1.4
@export var max_speed: float = 650.0

# Floor and ceiling bounds for gap placement
@export var floor_y: float = 720.0
@export var ceiling_y: float = 0.0



# Internal
var gap_size: float
var spawn_interval: float
var obstacle_speed: float
var spawn_timer: float = 0.0
var time_elapsed: float = 0.0
var obstacles: Array = []

@onready var player = $Character   # adjust if your node is named differently


func _ready():
	randomize()
	gap_size = starting_gap_size
	spawn_interval = starting_spawn_interval
	obstacle_speed = starting_speed


func _process(delta):
	time_elapsed += delta

	# ---- Automatic difficulty scaling ----
	gap_size = max(min_gap_size, gap_size - gap_shrink_rate * delta)
	spawn_interval = max(min_spawn_interval, spawn_interval - spawn_interval_decay * delta)
	obstacle_speed = min(max_speed, obstacle_speed + speed_increase_rate * delta)

	# ---- Spawn obstacles ----
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0
		generate_obstacle()

	# ---- Move and clean obstacles ----
	move_obstacles(delta)
	remove_offscreen_obstacles()
	
		# ---- Move and clean obstacles ----
	move_obstacles(delta)
	remove_offscreen_obstacles()

	# ---- Check if player goes off-screen ----
	check_player_bounds()

@onready var floor_node = get_node_or_null("StaticBody2D/Floor") if has_node("StaticBody2D/Floor") else find_child("Floor", true, false)
@onready var ceiling_node = get_node_or_null("StaticBody2D/Ceiling") if has_node("StaticBody2D/Ceiling") else find_child("Ceiling", true, false)

# Helper: compute the Y coordinate of the top edge of the floor (where floor starts)
func _get_floor_top_y() -> float:
	# fallback = bottom of viewport
	var vp_h = get_viewport().size.y
	if not floor_node:
		return vp_h
	# If floor has a CollisionShape2D (common), use its global position + extents
	var cs = floor_node.get_node_or_null("CollisionShape2D")
	if cs and cs.shape:
		var shape = cs.shape
		if shape is RectangleShape2D:
			var g = cs.get_global_transform().origin
			# rectangle's top = center_y - half_height
			return g.y - shape.extents.y
	# If it's a Control (ColorRect), its global transform origin is top-left; top edge = that y
	if floor_node is Control:
		return floor_node.get_global_transform().origin.y
	# last fallback: floor_node global Y (assume top is slightly above)
	if floor_node.has_method("get_global_transform"):
		return floor_node.get_global_transform().origin.y
	return vp_h

# Helper: compute the Y coordinate of the bottom edge of the ceiling (where corridor begins)
func _get_ceiling_bottom_y() -> float:
	# fallback = top of viewport
	if not ceiling_node:
		return 0.0
	var cs = ceiling_node.get_node_or_null("CollisionShape2D")
	if cs and cs.shape:
		var shape = cs.shape
		if shape is RectangleShape2D:
			var g = cs.get_global_transform().origin
			# rectangle's bottom = center_y + half_height
			return g.y + shape.extents.y
	if ceiling_node is Control:
		# Control's top-left + height gives bottom edge
		var g = ceiling_node.get_global_transform().origin
		var size = Vector2.ZERO
		if "size" in ceiling_node:
			size = ceiling_node.size
		return g.y + size.y
	if ceiling_node.has_method("get_global_transform"):
		var g = ceiling_node.get_global_transform().origin
		return g.y
	return 0.0

# Replace your existing generate_obstacle() with this:
func generate_obstacle():
	var viewport = get_viewport().size
	var screen_w = viewport.x

	# Get corridor bounds from ceiling & floor nodes (globals)
	var ceiling_bottom_y = _get_ceiling_bottom_y()
	var floor_top_y = _get_floor_top_y()

	# defensive clamp
	if floor_top_y <= ceiling_bottom_y:
		# fallback to full viewport if something's wrong
		ceiling_bottom_y = 0
		floor_top_y = viewport.y

	var corridor_height = floor_top_y - ceiling_bottom_y

	# decide gap center inside corridor (randomized so gap isn't always low)
	var gap_center_local = randf_range(corridor_height * 0.25, corridor_height * 0.75)
	var gap_variation = randf_range(-40.0, 40.0)
	gap_center_local = clamp(gap_center_local + gap_variation, gap_size * 0.5 + 8, corridor_height - gap_size * 0.5 - 8)

	# heights for top and bottom obstacles (measured from corridor edges)
	var wall_height_top = int(gap_center_local - (gap_size / 2.0))
	var wall_height_bottom = int(corridor_height - wall_height_top - gap_size)

	# spawn X (just offscreen to the right)
	var spawn_x = screen_w + 40

	# --- TOP OBSTACLE: center positioned within corridor below the ceiling ---
	var top_obstacle = ObstacleScene.instantiate()
	top_obstacle.wall_height = max(4, wall_height_top)
	# top obstacle center = ceiling bottom + half of its height
	top_obstacle.position = Vector2(spawn_x, ceiling_bottom_y + (top_obstacle.wall_height / 2.0))
	add_child(top_obstacle)
	obstacles.append(top_obstacle)

	# --- BOTTOM OBSTACLE: center positioned so its bottom edge aligns with floor top ---
	var bottom_obstacle = ObstacleScene.instantiate()
	bottom_obstacle.wall_height = max(4, wall_height_bottom)
	# center = floor_top_y - (height / 2) => bottom edge will be at floor_top_y
	bottom_obstacle.position = Vector2(spawn_x, floor_top_y - (bottom_obstacle.wall_height / 2.0))
	add_child(bottom_obstacle)
	obstacles.append(bottom_obstacle)

	# --- Visual layering: make bottom obstacle draw behind the floor so it looks cut-off ---
	# If Floor is a CanvasItem (Control/Node2D), try to set z_index of the obstacle's ColorRect.
	var floor_z = 0
	if floor_node and floor_node is CanvasItem:
		floor_z = floor_node.z_index

	# Try to set ColorRect z_index (obstacle.tscn uses ColorRect)
	var top_cr = top_obstacle.get_node_or_null("ColorRect")
	var bot_cr = bottom_obstacle.get_node_or_null("ColorRect")
	if top_cr and top_cr is CanvasItem:
		# draw top obstacle above the floor
		top_cr.z_index = floor_z + 1
	if bot_cr and bot_cr is CanvasItem:
		# draw bottom obstacle behind the floor so it appears to emerge from the floor
		bot_cr.z_index = floor_z - 1



# --------------------------------------------------
# Movement + Cleanup
# --------------------------------------------------
func move_obstacles(delta):
	for o in obstacles:
		o.position.x -= obstacle_speed * delta


func remove_offscreen_obstacles():
	for o in obstacles.duplicate():
		if o.global_position.x < -o.wall_width * 1.5:
			obstacles.erase(o)
			o.queue_free()
			
# --------------------------------------------------
# Player boundary check
# --------------------------------------------------
func check_player_bounds():
	if not player:
		return

	var viewport = get_viewport().size
	var px = player.global_position.x
	var py = player.global_position.y

	var half_width = 16.0
	var half_height = 16.0
	var active_shape: Shape2D = null

	# --- Determine which hitbox is active ---
	if player.has_node("SlidingHitBox") and not player.get_node("SlidingHitBox").disabled:
		active_shape = player.get_node("SlidingHitBox").shape
	elif player.has_node("StandingHitBox") and not player.get_node("StandingHitBox").disabled:
		active_shape = player.get_node("StandingHitBox").shape
	elif player.has_node("CollisionShape2D"):
		active_shape = player.get_node("CollisionShape2D").shape

	# --- Extract dimensions safely ---
	if active_shape:
		if active_shape is RectangleShape2D:
			half_width = active_shape.extents.x
			half_height = active_shape.extents.y
		elif active_shape is CapsuleShape2D:
			half_width = active_shape.radius
			half_height = active_shape.height * 0.5
		elif active_shape is CircleShape2D:
			half_width = active_shape.radius
			half_height = active_shape.radius

	# --- Define off-screen limits (half-body beyond screen) ---
	var left_limit = -half_width
	var right_limit = viewport.x + half_width
	var top_limit = -half_height
	var bottom_limit = viewport.y + half_height

	# --- Check if player is out of bounds ---
	if px < left_limit or px > right_limit or py < top_limit or py > bottom_limit:
		print("Player went off-screen (%.1f, %.1f). Closing game..." % [px, py])
		get_tree().quit()
