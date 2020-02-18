extends TileMap

var fighting = false
var rooms = {}

var maps = {
	"grass1":"res://Rooms/Grass1.tscn"
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

func _on_Player_new_map_signal(map_position):
	current_map_position = map_position

func change_map(map_name):
	pass

func _ready():
	randomize()

