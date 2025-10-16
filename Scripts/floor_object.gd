extends StaticBody2D

@export var canFollow : Array[PackedScene]
@export var height : Array[float] = [810.0]
@export var topCollidable : bool
@export var flippable : bool

var controller: Node = null;

func _ready():
	controller = get_tree().root.get_node("Level1/GameController");

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if controller:
		position.x -= controller.SPEED * delta;
		
	if position.x < -1200:
		queue_free()
