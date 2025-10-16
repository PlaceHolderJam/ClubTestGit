extends Node2D
@export var enabled : bool

@export var obstacles : Array[PackedScene]
@export var spawn_interval : Array = [.7, .9, 1.4]

@onready var globalTime = get_tree().root.get_node("Level1/Timer")
@onready var sceneFolder = $SceneFolder_Green

var started = false;
var lastObstacle;
var obstacleCount = 1;
var worldColor;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	obstacles = sceneFolder.obstacles
	worldColor = sceneFolder.modulateColor
	
	randomize();
	$Timer.wait_time = spawn_interval[0];
	$Timer.start();

func _on_timer_timeout() -> void:
	
	obstacles = sceneFolder.obstacles
	worldColor = sceneFolder.modulateColor
		
	if enabled:
		if not obstacles.is_empty():
			spawn_obstacle()
		$Timer.wait_time = spawn_interval.pick_random();
		obstacleCount += 1;

func spawn_obstacle():
	
	var obstacle_scene;
	var obstacle;
	
	if started == false:
		obstacle_scene = obstacles.pick_random()
		obstacle = obstacle_scene.instantiate()
		
		started = true;
		
	else:
		if lastObstacle.canFollow.is_empty():
			obstacle_scene = obstacles.pick_random()
			obstacle = obstacle_scene.instantiate()
			
		else:
			obstacle_scene = lastObstacle.canFollow.pick_random()
			obstacle = obstacle_scene.instantiate()
			
			
	
	obstacle.position = Vector2(2800, obstacle.height.pick_random())
	modifySprite(obstacle)
	lastObstacle = obstacle;
	
	add_child(obstacle)

func modifySprite(node: Node):
	var flipped = false
	
	if node.flippable:
		flipped = [true, false].pick_random()
	
	for sprite in node.get_children():
		if sprite is Sprite2D:
			#sprite.self_modulate = Color(0.714, 0.877, 0.672, 1.0)
			sprite.self_modulate = worldColor
			sprite.flip_h = flipped;
