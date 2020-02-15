extends Node2D

<<<<<<< HEAD
class Room:
	var pos = Vector2()

var rooms = {}

var maps = {
	"grass1":"res://Rooms/Grass1.tscn",
	"grass2":"res://Rooms/Grass2.tscn"	
}

var grass_enemies = {
	
}

var item = "res://Objects/Main/Item.tscn"

var current_map_position = Vector2()

func rand(mn, mx):
	return round((randf()*(mx-mn))+mn)

func spawn_item(id):
	var new_item = load(item).instance()
	self.add_child(new_item)

func spawn_enemy(enemy_name, position):
	var new_enemy = load(grass_enemies[enemy_name]).instance()
	self.add_child(new_enemy)
	if position:
		new_enemy.global_position = position
	else:
		new_enemy.global_position = Vector2(rand(0, 1334), rand(0, 736))

func _ready():
	randomize()

func _on_Player_new_map_signal(map_position):
	current_map_position = map_position
=======
var enemies = []

var rooms = {
	"grass1": "res://Rooms/Grass1.tscn"
}

func change_map(map_name):
	pass

func _ready():
	pass # Replace with function body.
>>>>>>> 4e9d3bfc3d3fc912f8366444fe3c40f0ca2d7c0b
