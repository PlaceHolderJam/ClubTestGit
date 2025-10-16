extends StaticBody2D

@export var canFollow : Array[PackedScene]
@export var height : Array[float] = [435]
@export var topCollidable : bool
@export var flippable : bool

var controller: Node = null;
var vert_speed = 24;
var bottom_y;

func _ready():
	controller = get_tree().root.get_node("Level1/GameController");
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if controller:
		position.x -= controller.SPEED * delta;
	
	bottom_y = $TopPart1.global_position.y + ($TopPart1.shape.extents.y * $TopPart1.global_scale.y)
	
	if bottom_y < 435:
		$TopPart1.position.y += delta * vert_speed
		$TopPart2.position.y += delta * vert_speed
		$Sprite2D.position.y += delta * vert_speed
		
		$TopPart1_2.position.y -= delta * vert_speed
		$TopPart2_2.position.y -= delta * vert_speed
		$Sprite2D2.position.y -= delta * vert_speed
	
	if position.x < -1200:
		queue_free()
