extends CanvasLayer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func update_health(new_value):
	$Health/Bar.value = new_value

func _on_Player_health_changed(new_health):
	update_health(new_health)

func show_new_item(id):
	var yreg = floor(id/5)
	var xreg = id%5
	$MarginContainer2/CenterContainer/VBoxContainer/CenterContainer2/TextureRect.texture.region = Rect2(xreg*32, yreg*32, 32, 32)
	$ItemShowTimer.start(2)
	$MarginContainer2.visible = true

func _on_ItemShowTimer_timeout():
	$MarginContainer2.visible = false


func _on_Map_cleared_room(num_rooms_cleared):
	$MarginContainer/CenterContainer/Label.text = "Rooms Cleared: "+str(num_rooms_cleared)
