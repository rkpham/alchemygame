extends KinematicBody2D

#Custom signals
signal health_changed
signal new_map_signal
signal grabbed_item

onready var camera = get_node("/root/Game/Camera2D")
onready var ASP = get_node("/root/Game/Audio")
onready var GUI = get_node("/root/Game/GUI")
const ITEM_GET = preload("res://Assets/Audio/SFX/ItemGet.wav")
const BULLET = preload("res://Objects/Projectiles/Bullet.tscn")
const SMOKE_PARTICLE = preload("res://Objects/Projectiles/Smoke.tscn")
export (int) var speed = 200

#Stats
var health = 100
var damage = 3
var invulnerable = false

#Items
var items = []

#Misc variables
var nearbyareas = []
var nearbyhurtareas = []

var walk_cycle = 0
var walk_rate = 5
var walk_bounce = true

var current_map_position = Vector2(0, 0)
var last_map_position = Vector2(0, 0)

#Controls variables
var allowedtomove = true

var velocity = Vector2()
var facing = Vector2()

var clicking = false
var clicking2 = false

var e = false
var w = false
var a = false
var s = false
var d = false

var horizontal = 0
var vertical = 0
var player_turn = 2

var fire_cycle = 1
var fire_rate = 0.1
var firing = false

#Hurt function
func hurt(x):
	if not invulnerable:
		health -= x
		camera.shake(0.25, 20, 3)
		emit_signal("health_changed", health)
		invulnerable = true
		$Sprite.material.set_shader_param("scale", 1)
		$InvulnerableFrames.start(0.4)
		pause(0.05)

#Freeze game for a time
func pause(length):
	get_tree().paused = true
	$Pause.start(length)

func _on_Pause_timeout():
	get_tree().paused = false

func die():
	camera.pause_mode = Node.PAUSE_MODE_PROCESS
	camera.shake(0.5, 10, 8)
	pause(5)
	$Death.start(3)

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
	clicking2 = Input.is_action_pressed('fire2')
	horizontal = int(d)-int(a)
	vertical = int(s)-int(w)
	velocity = Vector2(horizontal, vertical).normalized() * speed
	#Facing towards mouse
	facing = ((get_global_mouse_position())-global_position).normalized()

func _process(delta):
	if health <= 0:
		die()
	
	get_input()
	player_turn = direct8(facing)
	
	last_map_position = current_map_position
	current_map_position = (global_position/Vector2(640, 368)).floor()
	
	if last_map_position != current_map_position:
		emit_signal("new_map_signal", current_map_position)
	
	#Walking animation
	if (w || a || s || d):
		walk_cycle += 0.1
		walk_cycle = fmod(walk_cycle,walk_rate)
		walk_bounce = walk_cycle<(walk_rate/2)
		if walk_cycle <= 0.2:
			var n_smoke = SMOKE_PARTICLE.instance()
			n_smoke.smoke = true
			n_smoke.z_index = -1
			get_parent().add_child(n_smoke)
			n_smoke.global_position = global_position+Vector2(randi()%8-4,randi()%8-4)
			n_smoke.velocity = Vector2(0, 0)
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
					emit_signal("grabbed_item", id)
					match id:
						1:
							fire_rate*=0.75
						2:
							fire_rate*=0.5
						3:
							damage+=3
						4:
							damage+=5
						5:
							fire_rate*=0.75
						6:
							fire_rate*=0.5
						7:
							damage+=3
						8:
							damage+=5
						9:
							fire_rate*=0.75
						10:
							fire_rate*=0.5
						11:
							damage+=3
						12:
							damage+=5
						13:
							fire_rate*=0.75
						14:
							fire_rate*=0.5
						15:
							damage+=3
						16:
							damage+=5
						17:
							fire_rate*=0.75
						18:
							fire_rate*=0.5
						19:
							damage+=3
						20:
							damage+=5
						21:
							fire_rate*=0.75
						22:
							fire_rate*=0.5
						23:
							damage+=3
						24:
							damage+=5
	#Hurting
	for area in nearbyhurtareas:
		if "Enemy" in area.name:
			hurt(3)
	
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
	if allowedtomove:
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
		hurt(area.get_parent().get_parent().damage)
	nearbyhurtareas.append(area)

func _on_PlayerHurt_area_exited(area):
	if area in nearbyhurtareas:
		nearbyhurtareas.remove(nearbyhurtareas.find(area))

func _on_InvulnerableFrames_timeout():
	invulnerable = false
	$Sprite.material.set_shader_param("scale", 0)

func _on_Death_timeout():
	get_tree().quit()