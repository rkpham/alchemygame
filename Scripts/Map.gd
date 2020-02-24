extends TileMap

signal cleared_room

var maps = {
	"grass0":"res://Rooms/Grass0.tscn",
	"grass1":"res://Rooms/Grass1.tscn",
	"grass2":"res://Rooms/Grass2.tscn",
	"grass3":"res://Rooms/Grass3.tscn",
	"grass4":"res://Rooms/Grass4.tscn",
	"grass5":"res://Rooms/Grass5.tscn",
	"grass6":"res://Rooms/Grass6.tscn",
	"grass7":"res://Rooms/Grass7.tscn",
	"grass8":"res://Rooms/Grass8.tscn",
	"grass9":"res://Rooms/Grass9.tscn",
	"grass10":"res://Rooms/Grass10.tscn"
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
	for i in range(round(difficulty)):
		var enemykeys = enemy_pool.keys()
		var enemytospawn = enemykeys[randi()%enemykeys.size()]
		spawn_enemy(enemytospawn, current_map_position*Vector2(640,368)+Vector2(rand(50, 590), rand(50, 318)))

func _on_Player_new_map_signal(map_position):
	current_map_position = map_position
	if !rooms.has(current_map_position):
		$NewRoomEntered.start(1)
		var playerposition = $Player.global_position
		if playerposition.y < 0:
			playerposition.y = 368.0+fmod(playerposition.y, 368.0)
		if playerposition.x < 0:
			playerposition.x = 640.0+fmod(playerposition.x, 640.0)
		var playerpositionclamped = Vector2(clamp(fmod(playerposition.x, 640.0), 32.0, 608.0), clamp(fmod(playerposition.y, 368.0), 64.0, 336.0))
		var playerpositionclampedscaled = playerpositionclamped + current_map_position*Vector2(640,368)
		$Player.global_position = playerpositionclampedscaled
		if !num_completed_rooms%5 == 0:
			$Player.allowedtomove = false

func finish_room():
	if not (current_map_position in completedrooms):
		completedrooms.append(current_map_position)
		num_completed_rooms += 1
		emit_signal("cleared_room", num_completed_rooms)
		difficulty *= 1.13
		fighting = false

func _process(delta):
	if !rooms.has(current_map_position):
		if num_completed_rooms%5 == 0:
			new_room(current_map_position, 10)
			spawn_item(current_map_position*Vector2(640,368)+Vector2(320,184),randi()%24)
		else:
			new_room(current_map_position, rand(0,9))

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
		if "Bounds" in child.name:
			var newbounds = child.duplicate()
			self.add_child(newbounds)
			newbounds.global_position = newbounds.position+(position*Vector2(640, 368))+Vector2(0, 32)

func enemy_died(enemy):
	enemies.remove(enemies.find(enemy))
	if (enemies.size() == 0):
		finish_room()
		for door in doors[current_map_position]:
			door.open()

func new_room(position, id):
	if (id == 10):
		num_completed_rooms += 1
		emit_signal("cleared_room", num_completed_rooms)
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
	if rooms[current_map_position] != 10:
		for door in doors[current_map_position]:
			door.close()
			fighting = true
			$Player.allowedtomove = true
		spawn_enemies_difficulty_scaled()