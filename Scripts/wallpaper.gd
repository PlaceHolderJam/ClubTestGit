extends Node2D

@export var SPEED = 100;
@export var bg_width = 4545;

var bg1;
var bg2;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bg1 = $Green1;
	bg2 = $Green2;
	
	bg1.position.x = 0;
	bg2.position.x = bg_width;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	bg1.position.x -= SPEED * delta;
	#bg2.position.x -= SPEED * delta;
	
	if bg1.position.x < 100:
		bg1.position.x = 1000;
	#if bg2.position.x + bg_width < 0:
		#bg2.position.x = bg1.position.x + bg_width;
