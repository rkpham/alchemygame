extends KinematicBody2D

var ASP
const ITEM_GET = preload("res://Assets/Audio/SFX/ItemGet.wav")
const BULLET = preload("res://Objects/Projectiles/PotionProjectile.tscn")
export (int) var speed = 200

#Stats
var health = 100
var damage = 15

#Items
var items = []

#Misc variables
var nearbyareas = []

var walk_cycle = 0
var walk_rate = 10
var walk_bounce = true

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
var fire_rate = 0.1
var firing = false

#Function for firing a bullet
func fire():
	var n_bullet = BULLET.instance()
	get_parent().add_child(n_bullet)
	n_bullet.global_position = global_position + Vector2(0, 16)
	n_bullet.velocity = facing + velocity/300

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
	facing = (get_global_mouse_position()-global_position).normalized()

func _ready():
	ASP = get_node("/root/Game/Audio")

func _process(delta):
	get_input()
	player_turn = direct8(facing)
	
	if (w || a || s || d):
		walk_cycle += delta*20
		if walk_cycle > walk_rate:
			walk_cycle = 0
		walk_bounce = walk_cycle > (walk_rate/2)
	else:
		walk_cycle = 0
	
	if (e):
		for area in nearbyareas:
			if (area.name == "ItemBound"):
				var id = area.get_parent().id
				if items.find(id) == -1:
					items.append(id)
					area.get_parent().queue_free()
					ASP.stream = ITEM_GET
					ASP.play()
					print("Added item " + str(id))
	
	if (clicking):
		firing = true
	else:
		firing = false
	if (firing):
		if (fire_cycle > fire_rate):
			fire_cycle = 0
			fire()
		fire_cycle += delta
	else:
		fire_cycle = 0
	
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

func _physics_process(delta):
	velocity = move_and_slide(velocity)

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