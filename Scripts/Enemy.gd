extends KinematicBody2D

export (int) var speed = 20

#-------------------------------------------------------------#
#---------------------------Signals---------------------------#
#-------------------------------------------------------------#

#Signals for enemies
signal health_changed
signal died

#-------------------------------------------------------------#
#--------------------------Variables--------------------------#
#-------------------------------------------------------------#

onready var anim = $Sprite/AnimationPlayer
var health = 10
var maxhealth = 10

#Where the enemy wants to go
var target
var target_position

#AI behavior
var behavior = "walking"
var spear_charge = 0
var spear_charge_max = 10
var speardown = false

#General variables
var damage = 3
var velocity = Vector2()
var enemy_type = ""

const hurt_sound = preload("res://Assets/Audio/SFX/hurt.wav")

#-------------------------------------------------------------#
#--------------------------Functions--------------------------#
#-------------------------------------------------------------#

#Returns a random number between mn and mx
func rand(mn, mx):
	return round((randf()*(mx-mn))+mn)

func _ready():
	#Trying to fix shader problems (two different of the same enemy flashing at once)
	var shinematerial = ShaderMaterial.new()
	shinematerial.shader = load("res://Shaders/recolor.shader")
	$Sprite.material.set_shader_param("recolor", Color(1, 1, 1, 1))
	$Sprite.material.set_shader_param("scale", 0)
	
	#Set the target (the player)
	target = self.get_parent().get_node("Player")
	target_position = target.global_position
	
	#Finding out what kind of enemy it is; setting appropriate stats
	if self.has_node("Slime"):
		enemy_type = "Slime"
		health = 6
		maxhealth = 6
		speed = 20
		damage = 5
	if self.has_node("EliteSlime"):
		enemy_type = "EliteSlime"
		health = 15
		maxhealth = 15
		damage = 20
		speed = 20
	if self.has_node("MushroomSpear"):
		enemy_type = "MushroomSpear"
		health = 15
		maxhealth = 15
		speed = 60
	if self.has_node("Frog"):
		enemy_type = "Frog"
		behavior = "charging"
		health = 15 
		maxhealth = 15
		damage = 15
		speed = 0

func _physics_process(delta):
	#Move the the enemy if they should be walking/running
	if behavior == "walking" || behavior == "spearcharge":
		target_position = target.global_position
		velocity = (target_position-global_position).normalized()*speed
		velocity = move_and_slide(velocity)
	
	#Slime behaviors
	if enemy_type == "Slime" or enemy_type == "EliteSlime":
		if vectortocardinal(velocity, 4) == 0:
			anim.play("idleright")
		elif vectortocardinal(velocity, 4) == 1:
			anim.play("idleforward")
		elif vectortocardinal(velocity, 4) == 2:
			anim.play("idleleft")
		elif vectortocardinal(velocity, 4) == 3:
			anim.play("idleback")
	
	#Mushroom spear enemy behaviors
	if enemy_type == "MushroomSpear":
		#Doesn't move while idle
		if behavior == "idle":
			anim.play("idleforward")
		#Walk towards player until in range of charge
		if behavior == "walking":
			if (global_position - target_position).length() <= 100:
				behavior = "charging"
			if vectortocardinal(velocity, 4) == 0:
				anim.play("walkright")
			elif vectortocardinal(velocity, 4) == 1:
				anim.play("walkforward")
			elif vectortocardinal(velocity, 4) == 2:
				anim.play("walkleft")
			elif vectortocardinal(velocity, 4) == 3:
				anim.play("walkback")
		#Charge up the spear standing in place
		if behavior == "charging":
			if !speardown:
				speardown = true
				if vectortocardinal(velocity, 4) == 0:
					anim.play("stabright")
				elif vectortocardinal(velocity, 4) == 1:
					anim.play("stabforward")
				elif vectortocardinal(velocity, 4) == 2:
					anim.play("stableft")
				elif vectortocardinal(velocity, 4) == 3:
					anim.play("stabback")
			spear_charge += 0.1
			#When spear is fully charged...
			if spear_charge >= spear_charge_max:
				spear_charge = spear_charge_max
				behavior = "spearcharge"
		#Charge at the player
		if behavior == "spearcharge":
			if vectortocardinal(velocity, 4) == 0:
				anim.play("stabright")
			elif vectortocardinal(velocity, 4) == 1:
				anim.play("stabforward")
			elif vectortocardinal(velocity, 4) == 2:
				anim.play("stableft")
			elif vectortocardinal(velocity, 4) == 3:
				anim.play("stabback")
			
			#Keeps the spear pointed forwards while enemy is charging
			anim.seek(0.8)
			
			spear_charge = 0
			speed = 80
			damage = 30
			
			#Charge only lasts for 2 seconds
			if $ChargeTimer.is_stopped():
				$ChargeTimer.start(2)
	
	#Frog behaviors
	if enemy_type == "Frog":
		#Charges up a jump
		if behavior == "charging":
			speed = 0
			spear_charge += 0.1
			var lookatplayer = (target_position-global_position).normalized()
			if vectortocardinal(lookatplayer, 4) == 0:
				anim.play("idleright")
			elif vectortocardinal(lookatplayer, 4) == 1:
				anim.play("idleforward")
			elif vectortocardinal(lookatplayer, 4) == 2:
				anim.play("idleleft")
			elif vectortocardinal(lookatplayer, 4) == 3:
				anim.play("idleback")
		
		#Jump fully charged
		if spear_charge > spear_charge_max:
			behavior = "spearcharge"
		
		#Jump at player
		if behavior == "spearcharge":
			spear_charge = 0
			speed = 50
#			# need to fix animations for this guy
#			and make it so he stops after a jump, not anim finish
			var currentframe = anim.current_animation_position
			if vectortocardinal(velocity, 4) == 0:
				anim.play("jumpright")
			elif vectortocardinal(velocity, 4) == 1:
				anim.play("jumpforward")
			elif vectortocardinal(velocity, 4) == 2:
				anim.play("jumpleft")
			elif vectortocardinal(velocity, 4) == 3:
				anim.play("jumpback")
#Note: turn all of these if else statements into a function for animations

func _on_Area2D_area_entered(area):
	#Make mushroom boy stop charging if he hits you
	if area.name == "PlayerHurt":
		if enemy_type == "MushroomSpear":
			behavior = "idle"
			$IdleTimer.start(3)
	#Trying to fix enemies spawning in map walls accidentally
	if area.name == "Map":
		global_position = get_parent().current_map_position*Vector2(640,368)+Vector2(rand(50, 590), rand(50, 318))

func die():
	emit_signal("died", self)
	queue_free()

#Hurt the enemy
func hurt(x):
	health -= x
	$MarginContainer/TextureProgress.value = int((float(health)/maxhealth)*100)
	emit_signal("health_changed", x)
	$Sprite.material.set_shader_param("scale", 1)
	$HurtFrame.start(0.05)
	if (health <= 0):
		die()

#Don't know why this is here
func respectfulplayanim(animationname):
	if !anim.is_playing():
		anim.play(animationname)

#Function to turn a vector into a directional number
#ex. if vector was Vector(1,1), would return 7 if sectornum was 8
func vectortocardinal(vector, sectornum):
	var angle = atan2(vector.y, vector.x)
	var anglesector = int(round((sectornum*(angle/(2*PI)))+sectornum))%sectornum
	return anglesector

#-------------------------------------------------------------#
#--------------------------Connects---------------------------#
#-------------------------------------------------------------#

#Flash of white to indicate hurt
func _on_HurtFrame_timeout():
	$Sprite.material.set_shader_param("scale", 0)

#Shroom spear charge timer
func _on_ChargeTimer_timeout():
	speardown = false
	behavior = "idle"
	if $IdleTimer.is_stopped():
		$IdleTimer.start(3)

#Shroom spear after-charge cooldown timer
func _on_IdleTimer_timeout():
	behavior = "walking"

#Get rid of this and fix the frog please
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name.find("jump") != -1:
		behavior = "charging"
		speed = 0