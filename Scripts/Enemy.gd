extends KinematicBody2D

export (int) var speed = 20

signal health_changed

onready var anim = $Sprite/AnimationPlayer
var health = 10
var maxhealth = 10

var target
var target_position
var velocity = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	target = self.get_parent().get_node("Player")
	target_position = target.global_position

func _physics_process(delta):
	target_position = target.global_position
	velocity = (target_position-global_position).normalized()*speed
	velocity = move_and_slide(velocity)
	if vectortocardinal(velocity, 4) == 0:
		anim.play("idleright")
	elif vectortocardinal(velocity, 4) == 1:
		anim.play("idleforward")
	elif vectortocardinal(velocity, 4) == 2:
		anim.play("idleleft")
	elif vectortocardinal(velocity, 4) == 3:
		anim.play("idleback")

func _on_Area2D_area_entered(area):
	pass

func die():
	queue_free()

func hurt(x):
	health -= x
	$MarginContainer/TextureProgress.value = int((float(health)/maxhealth)*100)
	emit_signal("health_changed", x)
	if (health <= 0):
		die()

func respectfulplayanim(animationname):
	if !anim.is_playing():
		anim.play(animationname)

func vectortocardinal(vector, sectornum):
	var angle = atan2(vector.y, vector.x)
	var anglesector = int(round((sectornum*(angle/(2*PI)))+sectornum))%sectornum
	return anglesector