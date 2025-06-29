class_name GUI
extends Control

signal start_pressed

enum States {
	MAINMENU,
	GAMEMENU,
	PAUSED,
	GAME_OVER,
	OPTIONS
}

onready var menus = {
	States.MAINMENU : $MainMenu,
	States.GAMEMENU : $GameMenu
}

var current_state = States.MAINMENU
var previous_state = States.MAINMENU


func _ready():
	change_state(States.MAINMENU)


func change_state(new_state):
	previous_state = current_state
	current_state = new_state
	
	update_menu_visibility()
	
	update_game_state()


func hide_all_menus():
	for menu in menus.values():
		menu.hide()


func update_menu_visibility():
	hide_all_menus()
	
	# Sadece aktif ekranı göster
	menus[current_state].show()
	
	match current_state:
		_:
			pass


func update_game_state():
	match current_state:
		States.GAMEMENU:
			get_tree().paused = false
		States.PAUSED, States.GAME_OVER, States.MAINMENU, States.OPTIONS:
			get_tree().paused = true


func _on_Button_pressed():
	emit_signal("start_pressed")
	change_state(States.GAMEMENU)


func _on_Back_pressed():
	change_state(previous_state)
