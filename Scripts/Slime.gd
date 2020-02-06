extends KinematicBody2D

export (int) var speed = 20

var playerhurting
var target
var target_position
var velocity = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite/AnimationPlayer.play("idle")
	target = self.get_parent().get_node("Player")
	target_position = target.global_position

func _physics_process(delta):
	target_position = target.global_position
	velocity = (target_position-global_position).normalized()*speed
	velocity = move_and_slide(velocity)

func _on_Area2D_area_entered(area):
	if area.name == "PlayerHurt":
		area.get_parent().hurt(3)

func _on_Area2D_area_exited(area):
	pass
