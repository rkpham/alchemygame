extends KinematicBody2D

export (int) var speed = 20

signal health_changed
signal died

onready var anim = $Sprite/AnimationPlayer
var health = 10
var maxhealth = 10

var target
var target_position
var velocity = Vector2()
var enemy_type = ""
var behavior = "walking"
var spear_charge = 0
var spear_charge_max = 10
var speardown = false
var damage = 3

const hurt_sound = preload("res://Assets/Audio/SFX/hurt.wav")

# Called when the node enters the scene tree for the first time.
func _ready():
	target = self.get_parent().get_node("Player")
	target_position = target.global_position
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
	if behavior == "walking" || behavior == "spearcharge":
		target_position = target.global_position
		velocity = (target_position-global_position).normalized()*speed
		velocity = move_and_slide(velocity)
	
	if enemy_type == "Slime" or enemy_type == "EliteSlime":
		if vectortocardinal(velocity, 4) == 0:
			anim.play("idleright")
		elif vectortocardinal(velocity, 4) == 1:
			anim.play("idleforward")
		elif vectortocardinal(velocity, 4) == 2:
			anim.play("idleleft")
		elif vectortocardinal(velocity, 4) == 3:
			anim.play("idleback")
	
	if enemy_type == "MushroomSpear":
		if behavior == "idle":
			anim.play("idleforward")
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
			if spear_charge >= spear_charge_max:
				spear_charge = spear_charge_max
				behavior = "spearcharge"
		if behavior == "spearcharge":
			if vectortocardinal(velocity, 4) == 0:
				anim.play("stabright")
			elif vectortocardinal(velocity, 4) == 1:
				anim.play("stabforward")
			elif vectortocardinal(velocity, 4) == 2:
				anim.play("stableft")
			elif vectortocardinal(velocity, 4) == 3:
				anim.play("stabback")
			anim.seek(0.8)
			spear_charge = 0
			speed = 80
			damage = 30
			if $ChargeTimer.is_stopped():
				$ChargeTimer.start(2)
	
	if enemy_type == "Frog":
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
		if spear_charge > spear_charge_max:
			behavior = "spearcharge"
		if behavior == "spearcharge":
			spear_charge = 0
			speed = 50
			var currentframe = anim.current_animation_position
			if vectortocardinal(velocity, 4) == 0:
				anim.play("jumpright")
			elif vectortocardinal(velocity, 4) == 1:
				anim.play("jumpforward")
			elif vectortocardinal(velocity, 4) == 2:
				anim.play("jumpleft")
			elif vectortocardinal(velocity, 4) == 3:
				anim.play("jumpback")

func _on_Area2D_area_entered(area):
	if area.name == "PlayerHurt":
		if enemy_type == "MushroomSpear":
			behavior = "idle"
			$IdleTimer.start(3)

func die():
	emit_signal("died", self)
	queue_free()

func hurt(x):
	health -= x
	$MarginContainer/TextureProgress.value = int((float(health)/maxhealth)*100)
	emit_signal("health_changed", x)
	$Sprite.material.set_shader_param("scale", 1)
	$HurtFrame.start(0.05)
	if (health <= 0):
		die()

func respectfulplayanim(animationname):
	if !anim.is_playing():
		anim.play(animationname)

func vectortocardinal(vector, sectornum):
	var angle = atan2(vector.y, vector.x)
	var anglesector = int(round((sectornum*(angle/(2*PI)))+sectornum))%sectornum
	return anglesector

func _on_HurtFrame_timeout():
	$Sprite.material.set_shader_param("scale", 0)

func _on_ChargeTimer_timeout():
	speardown = false
	behavior = "idle"
	if $IdleTimer.is_stopped():
		$IdleTimer.start(3)

func _on_IdleTimer_timeout():
	behavior = "walking"

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name.find("jump") != -1:
		behavior = "charging"
		speed = 0