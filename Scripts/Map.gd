extends TileMap

signal cleared_room

var maps = {
	"grass0":"res://Rooms/Grass0.tscn"
}

var enemy_pool = {
	"slime":"res://Objects/Actors/Slime.tscn",
	"eliteslime":"res://Objects/Actors/EliteSlime.tscn",
	"mushroomspear":"res://Objects/Actors/MushroomSpear.tscn",
	"frog":"res://Objects/Actors/Frog.tscn"
}

var doors = {}

var rooms = {}

var enemies = []
var completedrooms = []
var fighting = true
var difficulty = 1

var item = "res://Objects/Main/Item.tscn"

var current_map_position = Vector2(0,0)
var num_completed_rooms = 0

func rand(mn, mx):
	return round((randf()*(mx-mn))+mn)

func spawn_item(position, id):
	var new_item = load(item).instance()
	self.add_child(new_item)
	new_item.global_position = position
	new_item.id = id
	print("Spawned item "+str(id)+" at"+str(position))

func spawn_enemy(enemy_name, position):
	var new_enemy = load(enemy_pool[enemy_name]).instance()
	self.add_child(new_enemy)
	enemies.append(new_enemy)
	new_enemy.connect("died", self, "enemy_died")
	if position:
		new_enemy.global_position = position

func spawn_enemies_difficulty_scaled():
	spawn_enemy("frog", current_map_position*Vector2(640,368)+Vector2(rand(50, 590), rand(50, 318)))

func _on_Player_new_map_signal(map_position):
	current_map_position = map_position
	if !rooms.has(current_map_position):
		$NewRoomEntered.start(1)

func finish_room():
	if not (current_map_position in completedrooms):
		completedrooms.append(current_map_position)
		num_completed_rooms += 1
		emit_signal("cleared_room", num_completed_rooms)

func _process(delta):
	if !rooms.has(current_map_position):
		new_room(current_map_position, rand(0,0))

func load_map(position, id):
	var loadedmap = load(maps["grass"+str(id)]).instance()
	for x in range(40):
		for y in range(23):
			var cellposition = Vector2((position.x*40)+x,(position.y*23)+y+2)
			var wallcell = loadedmap.get_cell(x,y)
			var wallcellautotile = loadedmap.get_cell_autotile_coord(x,y)
			var floorcell = loadedmap.get_node("Floor").get_cell(x,y)
			var floorcellautotile = loadedmap.get_node("Floor").get_cell_autotile_coord(x,y)
			var floorpropscell = loadedmap.get_node("FloorProps").get_cell(x,y)
			var floorpropscellautotile = loadedmap.get_node("FloorProps").get_cell_autotile_coord(x,y)
			set_cell(cellposition.x, cellposition.y, wallcell, false, false, false, wallcellautotile)
			$Floor.set_cell(cellposition.x, cellposition.y, floorcell, false, false, false, floorcellautotile)
			$FloorProps.set_cell(cellposition.x, cellposition.y, floorpropscell, false, false, false, floorpropscellautotile)
	var newdoorarray = []
	doors[position] = newdoorarray
	for child in loadedmap.get_children():
		if "Door" in child.name:
			var newdoor = child.duplicate()
			newdoorarray.append(newdoor)
			self.add_child(newdoor)
			newdoor.global_position = newdoor.position+(position*Vector2(640, 368))+Vector2(0, 32)

func enemy_died(enemy):
	enemies.remove(enemies.find(enemy))
	if (enemies.size() == 0):
		finish_room()
		for door in doors[current_map_position]:
			door.open()

func new_room(position, id):
	rooms[position] = id
	load_map(position, id)
	update_dirty_quadrants()

func _ready():
	randomize()
	new_room(Vector2(0,0),0)
	for door in doors[current_map_position]:
		door.close()
	update_dirty_quadrants()
	spawn_enemies_difficulty_scaled()

func _on_NewRoomEntered_timeout():
	for door in doors[current_map_position]:
		door.close()
	spawn_enemies_difficulty_scaled()