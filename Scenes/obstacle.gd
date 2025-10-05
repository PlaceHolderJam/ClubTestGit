# obstacle.gd
extends StaticBody2D

@export var wall_height: int = 100
@export var gap_size: int = 150
@export var wall_width: int = 50

func _ready():
	# Rectangle collision centered on the node origin
	var collision_shape = RectangleShape2D.new()
	collision_shape.extents = Vector2(wall_width * 0.5, wall_height * 0.5)
	$CollisionShape2D.shape = collision_shape
	$CollisionShape2D.position = Vector2.ZERO

	# ColorRect is a Control; position it so its center = this Node2D origin
	# (ColorRect uses top-left coordinates, so shift by half size).
	if $ColorRect:
		$ColorRect.size = Vector2(wall_width, wall_height)
		$ColorRect.position = Vector2(-wall_width * 0.5, -wall_height * 0.5)
