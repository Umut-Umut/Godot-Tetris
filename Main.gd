extends Node2D


onready var gui : GUI = get_node("CanvasLayer/GUI")
onready var scene_board : PackedScene = preload("res://Board.tscn")


var is_game_init : bool = false


func _ready():
	get_tree().paused = true
	
	$BoardTemp.queue_free()


func _input(event):
	if event is InputEventKey:
		if event.pressed and not event.is_echo():
			if event.scancode == KEY_P:
				get_tree().paused = not get_tree().paused


func game_init():
	var board : Board = scene_board.instance()
	add_child(board)
	
	get_tree().paused = false
	
	is_game_init = true


func _on_GUI_start_pressed():
	if is_game_init:
		return
	game_init()

