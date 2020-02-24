extends Sprite

onready var anim = $AnimationPlayer

func open():
	if ("North" in name or "South" in name):
		anim.play("open")
	$StaticBody2D.set_collision_layer_bit(0, false)
	$StaticBody2D.set_collision_mask_bit(0, false)

func close():
	if ("North" in name or "South" in name):
		anim.play_backwards("open")
	$StaticBody2D.set_collision_layer_bit(0, true)
	$StaticBody2D.set_collision_mask_bit(0, true)