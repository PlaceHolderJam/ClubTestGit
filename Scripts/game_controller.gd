extends Node2D

@export var SPEED = 1600.0

@onready var globalTime = get_tree().root.get_node("Level1/Timer")
@onready var spawner = get_tree().root.get_node("Level1/ObstacleSpawner")

var currTime;
var currSpeed;
var timeCheck1 = false;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

	currTime = 120
	currSpeed = SPEED;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if currSpeed > SPEED:
		SPEED += .5;
	else:
		if currTime > int(globalTime.time_left):
			currTime = int(globalTime.time_left)
			SPEED += 3
			currSpeed = SPEED;
			print_debug(SPEED)
			print_debug(int(globalTime.time_left))
	
	if int(globalTime.time_left) <= 101 and int(globalTime.time_left) > 100:
		spawner.enabled = false;
		spawner.started = false
		
		spawner.sceneFolder = spawner.get_node("SceneFolder_Garage")
		
	if int(globalTime.time_left) <= 98 and int(globalTime.time_left) > 96:
		
		spawner.enabled = true;
		
	
