extends TileMap

#-------------------------------------------------------------#
#---------------------------Signals---------------------------#
#-------------------------------------------------------------#

signal cleared_room

#-------------------------------------------------------------#
#--------------------------Variables--------------------------#
#-------------------------------------------------------------#

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

#-------------------------------------------------------------#
#--------------------------Functions--------------------------#
#-------------------------------------------------------------#

#Return a random number between mn and mx
func rand(mn, mx):
	return round((randf()*(mx-mn))+mn)

#Spawn an item at position with id
func spawn_item(position, id):
	var new_item = load(item).instance()
	self.add_child(new_item)
	new_item.global_position = position
	new_item.id = id
	print("Spawned item "+str(id)+" at"+str(position))

#Spawn an enemy 
func spawn_enemy(enemy_name, position):
	#Instance the enemy from enemy_pool
	var new_enemy = load(enemy_pool[enemy_name]).instance()
	
	#Add the enemy to the world
	self.add_child(new_enemy)
	
	#Add the enemy to the array so we know it exists
	enemies.append(new_enemy)
	
	#If the enemy dies, we know
	new_enemy.connect("died", self, "enemy_died")
	
	#Move the enemy to it's position
	new_enemy.global_position = position

#note: spawning enemy and spawning item have swapped params; sad

#Spawns a number of enemies depending on difficulty
#Please make it more complicated than just rounding the var difficulty
#(Enemy rarities???)
func spawn_enemies_difficulty_scaled():
	for i in range(round(difficulty)):
		#Gets all the enemy names in enemy_pool
		var enemykeys = enemy_pool.keys()
		
		#Picks a random enemy name out of those names
		var enemytospawn = enemykeys[randi()%enemykeys.size()]
		
		#Spawn that enemy
		spawn_enemy(enemytospawn, current_map_position*Vector2(640,368)+Vector2(rand(50, 590), rand(50, 318)))

#Function to finish the current room
func finish_room():
	#If it's not already completed...
	if not (current_map_position in completedrooms):
		#Add to completed rooms array
		completedrooms.append(current_map_position)
		#Increment number of completed rooms
		num_completed_rooms += 1
		#Emit a signal saying the room was cleared
		emit_signal("cleared_room", num_completed_rooms)
		#Scale difficulty
		difficulty *= 1.13
		fighting = false

#Function to load a map
func load_map(position, id):
	#Load the map we want
	var loadedmap = load(maps["grass"+str(id)]).instance()
	
	for x in range(40):
		for y in range(23):
			
			#Get all the tilemap data
			var cellposition = Vector2((position.x*40)+x,(position.y*23)+y+2)
			var wallcell = loadedmap.get_cell(x,y)
			var wallcellautotile = loadedmap.get_cell_autotile_coord(x,y)
			var floorcell = loadedmap.get_node("Floor").get_cell(x,y)
			var floorcellautotile = loadedmap.get_node("Floor").get_cell_autotile_coord(x,y)
			var floorpropscell = loadedmap.get_node("FloorProps").get_cell(x,y)
			var floorpropscellautotile = loadedmap.get_node("FloorProps").get_cell_autotile_coord(x,y)
			
			#Set all of the corresponding cells in the world tilemap
			set_cell(cellposition.x, cellposition.y, wallcell, false, false, false, wallcellautotile)
			$Floor.set_cell(cellposition.x, cellposition.y, floorcell, false, false, false, floorcellautotile)
			$FloorProps.set_cell(cellposition.x, cellposition.y, floorpropscell, false, false, false, floorpropscellautotile)
	
	#Add all doors and bounds needed, as they're not part of the tileset
	#Check map .tscn's if you need to understand why
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

func _process(delta):
	if !rooms.has(current_map_position):
		#Add new rooms as you go along, along with item rooms every 5
		if num_completed_rooms%5 == 0:
			new_room(current_map_position, 10)
			spawn_item(current_map_position*Vector2(640,368)+Vector2(320,184),randi()%24)
		else:
			new_room(current_map_position, rand(0,9))

#Connected to enemy death
func enemy_died(enemy):
	#Remove the enemy from the array
	enemies.remove(enemies.find(enemy))
	#If this was the last enemy, finish the room
	if (enemies.size() == 0):
		finish_room()
		for door in doors[current_map_position]:
			door.open()

#Create a new rooms at position (map position, not pixel position)
func new_room(position, id):
	#If it's an item room
	if (id == 10):
		num_completed_rooms += 1
		emit_signal("cleared_room", num_completed_rooms)
	#Add to rooms dictionary
	rooms[position] = id
	#Load the tiles
	load_map(position, id)
	#Function for updating collision boxes and stuff (built-in)
	update_dirty_quadrants()

func _ready():
	randomize()
	#Creates the first room
	new_room(Vector2(0,0),0)
	for door in doors[current_map_position]:
		door.close()
	spawn_enemies_difficulty_scaled()

#Gets signalled when player enters a map position that
#was different from the map position last frame
func _on_Player_new_map_signal(map_position):
	#Update current map position var
	current_map_position = map_position
	#Check if it's a new room
	if !rooms.has(current_map_position):
		#Start the timer for going into a new room
		$NewRoomEntered.start(1)
		#Clamp the player's position so they are far enough
		#away from the door that they can't get back through before
		#the doors shut
		var playerposition = $Player.global_position
		if playerposition.y < 0:
			playerposition.y = 368.0+fmod(playerposition.y, 368.0)
		if playerposition.x < 0:
			playerposition.x = 640.0+fmod(playerposition.x, 640.0)
		var playerpositionclamped = Vector2(clamp(fmod(playerposition.x, 640.0), 32.0, 608.0), clamp(fmod(playerposition.y, 368.0), 64.0, 336.0))
		var playerpositionclampedscaled = playerpositionclamped + current_map_position*Vector2(640,368)
		$Player.global_position = playerpositionclampedscaled
		
		#Stop player from moving for a bit, unless it's an item room
		if !num_completed_rooms%5 == 0:
			$Player.allowedtomove = false

#A little bit of a pause before loading stuff in
func _on_NewRoomEntered_timeout():
	if rooms[current_map_position] != 10:
		for door in doors[current_map_position]:
			door.close()
			fighting = true
			#Allow player to move after a bit, we don't want them to
			#run back into the other room before enemies spawn
			$Player.allowedtomove = true
		spawn_enemies_difficulty_scaled()