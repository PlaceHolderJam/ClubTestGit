extends Panel

@onready var timer = get_tree().root.get_node("Level1/Timer")
@onready var time = $Time

var seconds = 121

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.start(seconds)
	time.text = "2:00"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	time.text = "%d:%02d" % [int(timer.time_left / 60), int(timer.time_left) % 60]
