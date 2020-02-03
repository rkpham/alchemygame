extends KinematicBody2D

export (int) var speed = 20

#Different enemy behaviors
enum behaviors {
	chase
}

var player
var player_position
var custom_enemy_behavior = []
#Different enemy behaviors are (chase)
var enemy_behavior = behaviors.chase

var velocity = Vector2()

#Get player info, play animation
func _ready():
	player = get_node("/root/Game/TileMap/Player")
	player_position = player.global_position
	$Sprite/AnimationPlayer.play()

#Enemy behavior
func _process(delta):
	player_position = player.global_position
	if enemy_behavior == behaviors.chase:
		velocity = (player_position-global_position).normalized()*speed

func _physics_process(delta):
	velocity = move_and_slide(velocity)