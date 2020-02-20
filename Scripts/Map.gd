extends TileMap

var maps = {
	"grass0":"res://Rooms/Grass0.tscn",
	"grass1":"res://Rooms/Grass1.tscn",
	"grass2":"res://Rooms/Grass2.tscn",
	"grass3":"res://Rooms/Grass3.tscn"
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

func load_map(position, id):
	var loadedmap = load(maps["grass"+str(id)]).instance()
	for x in range(40):
		for y in range(21):
			var cellposition = Vector2((position.x*40)+x,(position.y*21)+y+2)
			var wallcell = loadedmap.get_cell(x,y)
			var wallcellautotile = loadedmap.get_cell_autotile_coord(x,y)
			var floorcell = loadedmap.get_node("Floor").get_cell(x,y)
			var floorcellautotile = loadedmap.get_node("Floor").get_cell_autotile_coord(x,y)
			var floorpropscell = loadedmap.get_node("FloorProps").get_cell(x,y)
			var floorpropscellautotile = loadedmap.get_node("FloorProps").get_cell_autotile_coord(x,y)
			set_cell(cellposition.x, cellposition.y, wallcell, false, false, false, wallcellautotile)
			$Floor.set_cell(cellposition.x, cellposition.y, floorcell, false, false, false, floorcellautotile)
			$FloorProps.set_cell(cellposition.x, cellposition.y, floorpropscell, false, false, false, floorpropscellautotile)
			update_dirty_quadrants()
	for child in loadedmap.get_children():
		if "Door" in child.name:
			var newdoor = child.duplicate()
			self.add_child(newdoor)
			newdoor.global_position = newdoor.position+(position*Vector2(640, 368))+Vector2(0, 32)

func _ready():
	randomize()
	for x in range(7):
		for y in range(7):
			rooms[x][y] = rand(0, 3)
	rooms[0][0] = 0
	for x in range(7):
		for y in range(7):
			load_map(Vector2(x,y), rooms[x][y])