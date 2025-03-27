extends Node2D


onready var board : Board = get_parent()


func _ready():
	for i in range(board.HEIGHT + 2):
		for j in range(board.WIDTH + 2):
			if i == 0:
				var label = Label.new()
				label.rect_scale = 0.75 * Vector2.ONE
				label.text = str(j) + ", " + str(i)
				add_child(label)
				
				label.rect_position = board.map_to_world(Vector2(j, i))
			elif j == 0:
				var label = Label.new()
				label.rect_scale = 0.75 * Vector2.ONE
				label.text = str(j) + ", " + str(i)
				add_child(label)
				
				label.rect_position = board.map_to_world(Vector2(j, i))
