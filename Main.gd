extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = true


func _input(event):
	if event is InputEventKey:
		if event.pressed and not event.is_echo():
			if event.scancode == KEY_P:
				get_tree().paused = not get_tree().paused


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
