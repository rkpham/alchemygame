extends Sprite

export (int) var speed = 150
var velocity = Vector2()

var global_target_position

func move(delta):
	global_target_position = global_position + velocity
	self.look_at(global_target_position)
	global_position = global_target_position

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	velocity = velocity.normalized() * speed * delta
	move(delta)

func _on_Timer_timeout():
	queue_free()