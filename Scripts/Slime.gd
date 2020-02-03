extends KinematicBody2D

export (int) var speed = 20

var playerhurting
var player
var player_position
var velocity = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite/AnimationPlayer.play("idle")
	player = get_node("/root/Game/TileMap/Player")
	player_position = player.global_position

func _physics_process(delta):
	player_position = player.global_position
	velocity = (player_position-global_position).normalized()*speed
	velocity = move_and_slide(velocity)

func _on_Area2D_area_entered(area):
	if area.name == "PlayerHurt":
		area.get_parent().hurt(3)

func _on_Area2D_area_exited(area):
	pass
