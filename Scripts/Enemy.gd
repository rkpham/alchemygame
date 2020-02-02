extends KinematicBody2D

export (int) var speed = 200

var player_position
var custom_enemy_behavior = []
var enemy_behavior = "chase"

var velocity = Vector2()

func _ready():
	player_position = get_node("/root/Game/TileMap/Player").global_position
	$Sprite/AnimationPlayer.play()

func _physics_process(delta):
	if enemy_behavior == "chase":
		pass