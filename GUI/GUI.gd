class_name GUI
extends Control

signal start_pressed


onready var MainMenu = get_node("MainMenu")


func _ready():
	pass


func _on_Button_pressed():
	emit_signal("start_pressed")
