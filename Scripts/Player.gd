extends KinematicBody2D

const bullet = preload("res://Objects/Projectiles/PotionProjectile.tscn")
export (int) var speed = 200

var velocity = Vector2()
var facing = Vector2()

var w = false
var a = false
var s = false
var d = false
var up = false
var left = false
var down = false
var right = false

var horizontal = 0
var vertical = 0
var horizontal2 = 0
var vertical2 = 0
var player_turn = 2

var fire_cycle = 0
var fire_rate = 0.5
var firing = false

func fire():
	var n_bullet = bullet.instance()
	get_parent().add_child(n_bullet)
	n_bullet.global_position = global_position
	n_bullet.velocity = facing + velocity/300

func direct8(direction):
	var angle = direction.angle()
	if angle < 0:
		angle += 2 * PI
	var index = round(angle / PI * 4)
	return index

func get_input():
	w = Input.is_action_pressed('up')
	a = Input.is_action_pressed('left')
	s = Input.is_action_pressed('down')
	d = Input.is_action_pressed('right')
	up = Input.is_action_pressed('up2')
	left = Input.is_action_pressed('left2')
	down = Input.is_action_pressed('down2')
	right = Input.is_action_pressed('right2')
	horizontal = int(d)-int(a)
	vertical = int(s)-int(w)
	horizontal2 = int(right)-int(left)
	vertical2 = int(down)-int(up)
	velocity = Vector2(horizontal, vertical).normalized() * speed
	facing = Vector2(horizontal2, vertical2).normalized()
 
func _process(delta):
	if (up || left || down || right):
		firing = true
		player_turn = direct8(facing)
	elif (w || a || s || d):
		firing = false
		player_turn = direct8(Vector2(horizontal, vertical))
	else:
		firing = false
		player_turn = 2
	
	if (firing):
		if (fire_cycle > fire_rate):
			fire_cycle = 0
			fire()
		fire_cycle += delta
	else:
		fire_cycle = 0
	
	if (player_turn == 0):
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.frame = 4
	elif (player_turn == 1):
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.frame = 3
	elif (player_turn == 2):
		$AnimatedSprite.frame = 1
	elif (player_turn == 3):
		$AnimatedSprite.flip_h = true
		$AnimatedSprite.frame = 3
	elif (player_turn == 4):
		$AnimatedSprite.flip_h = true
		$AnimatedSprite.frame = 4
	elif (player_turn == 5):
		$AnimatedSprite.frame = 2
	elif (player_turn == 6):
		$AnimatedSprite.frame = 0
	elif (player_turn == 7):
		$AnimatedSprite.frame = 2

func _physics_process(delta):
	get_input()
	velocity = move_and_slide(velocity)