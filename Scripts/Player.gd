extends KinematicBody2D

#Custom signals
signal health_changed
signal new_map_signal

onready var camera = get_node("/root/Game/Camera2D")
onready var ASP = get_node("/root/Game/Audio")
onready var GUI = get_node("/root/Game/GUI")
const ITEM_GET = preload("res://Assets/Audio/SFX/ItemGet.wav")
const BULLET = preload("res://Objects/Projectiles/PotionProjectile.tscn")
export (int) var speed = 200

#Stats
var health = 100
var damage = 3

#Items
var items = []

#Misc variables
var nearbyareas = []

var walk_cycle = 0
var walk_rate = 10
var walk_bounce = true

var current_map_position = Vector2()

#Controls variables
var velocity = Vector2()
var facing = Vector2()

var clicking = false

var e = false
var w = false
var a = false
var s = false
var d = false

var horizontal = 0
var vertical = 0
var player_turn = 2

var fire_cycle = 0
var fire_rate = 1
var firing = false

#Hurt function
func hurt(x):
	health -= x
	camera.shake(0.25, 50, 3)
	emit_signal("health_changed", health)
	pause(0.04)

#Freeze game for a time
func pause(length):
	get_tree().paused = true
	$Pause.start(length)

func _on_Pause_timeout():
	get_tree().paused = false

#Function for firing a bullet
func fire():
	var n_bullet = BULLET.instance()
	get_parent().add_child(n_bullet)
	n_bullet.global_position = global_position
	n_bullet.velocity = facing
	n_bullet.damage = damage

#function to turn vector of facing into 8 directions, for sprite
func direct8(direction):
	var angle = direction.angle()
	if angle < 0:
		angle += 2 * PI
	var index = round(angle / PI * 4)
	return index

func get_input():
	e = Input.is_action_pressed('interact')
	w = Input.is_action_pressed('up')
	a = Input.is_action_pressed('left')
	s = Input.is_action_pressed('down')
	d = Input.is_action_pressed('right')
	clicking = Input.is_action_pressed('fire')
	horizontal = int(d)-int(a)
	vertical = int(s)-int(w)
	velocity = Vector2(horizontal, vertical).normalized() * speed
	#Facing towards mouse
	facing = ((get_global_mouse_position())-global_position).normalized()

func _process(delta):
	get_input()
	player_turn = direct8(facing)
	
	current_map_position = (global_position/Vector2(640, 368)).floor()
	
	#Walking animation
	if (w || a || s || d):
		walk_cycle += delta*20
		if walk_cycle > walk_rate:
			walk_cycle = 0
		walk_bounce = walk_cycle > (walk_rate/2)
	else:
		walk_cycle = 0
	
	#Interacting with nearby items
	if (e):
		for area in nearbyareas:
			if (area.name == "ItemBound"):
				var id = area.get_parent().id
				#If not already in the items array
				if items.find(id) == -1:
					items.append(id)
					area.get_parent().queue_free()
					#Play sound
					ASP.stream = ITEM_GET
					ASP.play()
					print("Added item " + str(id))
	
	#Shooting
	if (clicking):
		firing = true
	else:
		firing = false
	if (fire_cycle < fire_rate):
		fire_cycle += delta
	if (firing):
		if (fire_cycle >= fire_rate):
			fire_cycle = 0
			fire()
	
	#Turns the player towards the mouse
	if (player_turn == 0):
		$Sprite.frame = 2 + int(walk_bounce)*8
	elif (player_turn == 1):
		$Sprite.frame = 1 + int(walk_bounce)*8
	elif (player_turn == 2):
		$Sprite.frame = 0 + int(walk_bounce)*8
	elif (player_turn == 3):
		$Sprite.frame = 7 + int(walk_bounce)*8
	elif (player_turn == 4):
		$Sprite.frame = 6 + int(walk_bounce)*8
	elif (player_turn == 5):
		$Sprite.frame = 5 + int(walk_bounce)*8
	elif (player_turn == 6):
		$Sprite.frame = 4 + int(walk_bounce)*8
	elif (player_turn == 7):
		$Sprite.frame = 3 + int(walk_bounce)*8

#Move the player
func _physics_process(delta):
	velocity = move_and_slide(velocity)

#Checking for items in reach of the player
func _on_ItemReach_area_entered(area):
	if area.name == "ItemBound":
		if nearbyareas.find(area) == -1:
			nearbyareas.append(area)
		area.get_parent().outline = true

func _on_ItemReach_area_exited(area):
	if area.name == "ItemBound":
		if nearbyareas.find(area) != -1:
			nearbyareas.remove(nearbyareas.find(area))
		area.get_parent().outline = false

func _on_PlayerHurt_area_entered(area):
	if area.name == "Enemy":
		hurt(3)