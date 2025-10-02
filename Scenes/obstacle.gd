extends StaticBody2D

@export var SPEED =1200.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position.x -= delta * SPEED
