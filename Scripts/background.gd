extends Node2D

@export var SPEED = 1300;

@onready var globalTime = get_tree().root.get_node("Level1/Timer")
@onready var globalEnv = get_tree().root.get_node("Level1/WorldEnvironment")

@onready var entrance = $Transitions/Entrance
@onready var mid = $Transitions/Midsection
@onready var exit = $Transitions/Exit
@onready var folder = $BGFolder_Green

var temp;
var bg1;
var bg2;
var bg1_temp;
var bg2_temp;
var transitioning = false;
var timeCheck = false;

var controller : Node = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	controller = get_tree().root.get_node("Level1/GameController");
	
	if not folder.visible:
		folder.visible = true;
	
	globalEnv.environment = null
	
	SPEED = controller.SPEED - 150

	bg1 = folder.get_node("BG1")
	bg2 = folder.get_node("BG2")
	
	bg1.position = Vector2(0, 60);
	bg2.position = Vector2(getWidth(bg1), 60);
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	SPEED = controller.SPEED - 100
	
	bg1.position.x -= SPEED * delta;
	bg2.position.x -= SPEED * delta;
	
	if bg1_temp:
		bg1_temp.position.x -= SPEED * delta;
		bg2_temp.position.x -= SPEED * delta;
	
	if not transitioning:
		if bg1.position.x + getWidth(bg1) < 0:
			bg1.position.x = bg2.position.x + getWidth(bg1);
		if bg2.position.x + getWidth(bg1) < 0:
			bg2.position.x = bg1.position.x + getWidth(bg1);
	elif transitioning:
		entrance.position.x -= SPEED * delta;
		mid.position.x -= SPEED * delta;
		exit.position.x -= SPEED * delta;
		
		if entrance.position.x + getWidth(entrance) < 0:
			folder.visible = false;
		
		if exit.position.x + getWidth(bg1) < 0:
			$Transitions.visible = false;
			transitioning = false
			folder = temp;
			bg1 = bg1_temp;
			bg2 = bg2_temp;
			bg1_temp = null;
			bg2_temp = null;
			temp = null;
			
	if int(globalTime.time_left) <= 100 and timeCheck == false: #100
		timeCheck = true;
		transition($BGFolder_Garage)
	
func getWidth(node: Node) -> float:
	return node.get_node("CollisionShape2D").shape.extents.x * 2 * node.scale.x
	
func transition(node: Node):
	
	$Transitions.visible = true;
	transitioning = true;
	
	entrance.position = Vector2(2000, 60);
	mid.position = Vector2(entrance.position.x + getWidth(entrance), 60);
	exit.position = Vector2(mid.position.x + getWidth(mid), 60);
	
	temp = node;
	
	if not node.visible:
		node.visible = true;
	
	bg1_temp = node.get_node("BG1")
	bg2_temp = node.get_node("BG2")
	
	bg1_temp.position = Vector2(exit.position.x + getWidth(exit), 60);
	bg2_temp.position = Vector2(bg1_temp.position.x + getWidth(bg1_temp), 60);
