extends Sprite

#-------------------------------------------------------------#
#--------------------------Variables--------------------------#
#-------------------------------------------------------------#

export (int) var id = 0
var outline = false
var float_cycle = 0
var float_cycle_end = PI
var float_speed = 2
var float_amp = 10

#-------------------------------------------------------------#
#--------------------------Functions--------------------------#
#-------------------------------------------------------------#

func _ready():
	self.frame = id

func _process(delta):
	self.frame = id
	material.set_shader_param("outLineSize" , int(outline)*0.005)
	float_cycle += delta * float_speed
	float_cycle = fmod(float_cycle, float_cycle_end)
	offset = Vector2(0, sin(float_cycle)*float_amp-float_amp)