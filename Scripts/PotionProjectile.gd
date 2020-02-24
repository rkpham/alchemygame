extends Sprite

const GLASS_PARTICLE = preload("res://Objects/Projectiles/Glass.tscn")
export (int) var speed = 150
var velocity = Vector2()

var damage = 3

var global_target_position

func move(delta):
	global_target_position = global_position + velocity
	#self.look_at(global_target_position)
	global_position = global_target_position

func _physics_process(delta):
	velocity = velocity.normalized() * speed * delta
	move(delta)

func splash():
	queue_free()
	for i in range(5):
		var n_glass = GLASS_PARTICLE.instance()
		get_parent().add_child(n_glass)
		n_glass.global_position = global_position
		var randomx = randi()%300-150
		var randomy = randi()%300-150
		n_glass.velocity = Vector2(randomx, randomy)
	self.visible = false

func _on_Timer_timeout():
	splash()

func _on_Area2D_body_entered(body):
	if body.name == "Map":
		splash()
	if "Enemy" in body.name:
		body.hurt(damage)
		splash()
