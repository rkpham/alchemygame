extends CanvasLayer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func update_health(new_value):
	$HealthContainer/Text


func _on_Player_health_changed():
	pass # Replace with function body.
