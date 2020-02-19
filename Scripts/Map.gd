extends TileMap

var maps = {
	"grass1":"res://Rooms/Grass1.tscn"
}

var rooms = [[0, 0, 0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0, 0, 0],
			[0, 0, 0, 0, 0, 0, 0]]

var grass_enemies = {
	
}

var item = "res://Objects/Main/Item.tscn"

var current_map_position = Vector2()

func rand(mn, mx):
	return round((randf()*(mx-mn))+mn)

func spawn_item(position, id):
	var new_item = load(item).instance()
	self.add_child(new_item)
	new_item.global_position = position
	new_item.id = id
	print("Spawned item "+str(id)+" at"+str(position))

func spawn_enemy(enemy_name, position):
	var new_enemy = load(grass_enemies[enemy_name]).instance()
	self.add_child(new_enemy)
	if position:
		new_enemy.global_position = position
	else:
		new_enemy.global_position = Vector2(rand(0, 1334), rand(0, 736))

func _on_Player_new_map_signal(map_position):
	current_map_position = map_position

func add_map(position, id):
	for x in range(16):
		for y in range(16):
			pass

func _ready():
	randomize()
	spawn_item(Vector2(250,250), rand(0,24))
	for x in range(7):
		for y in range(7):
			rooms[x][y] = rand(0, 15)
	rooms[0][0] = 0
	for x in range(7):
		for y in range(7):
			add_map(Vector2(x,y), rooms[x][y])