extends Node2D

func _ready():
	# Set appropriate game resolution
	var screen_size = OS.get_screen_size()
	if int(fmod(screen_size.x, 640)) == fmod(screen_size.x, 640):
		print("Screen is 16:9")
		var screen_size_set = Vector2(640, 360)
		OS.window_size = screen_size_set
	elif int(fmod(screen_size.x, 683)) == fmod(screen_size.x, 683):
		print("Screen is 1366x768")
		var screen_size_set = Vector2(683, 384)
		OS.window_size = screen_size_set