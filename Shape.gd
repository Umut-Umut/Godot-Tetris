class_name TShape
extends TileMap


enum TColor {
	CYAN,
	PURPLE,
	YELLOW,
	RED,
	GREEN,
	ORANGE,
	BLUE,
	GREY
}

enum SHAPE {
	C,
	L,
	#S,
	#T
}


var shapes : Dictionary = {
	 SHAPE.C : {"color" : 3, "state" : 0, "rotations" : 1, "patterns" : [
		[[0, 0], [0, 1], [1, 0], [1, 1]],
		]},
	SHAPE.L : {"color" : 3, "state" : 0, "rotations" : 3, "patterns" : [
		[[0, 0], [0, 1], [0, 2], [1, 2]],
		[[0, 2], [1, 2], [2, 2], [2, 1]],
		[[2, 0], [2, 1], [2, 2], [1, 2]]
		]},
}


func set_shape(shape : int):
	clear()
	
	var c : Vector2 = Vector2(shapes[shape]["color"], 0)
	for vector in shapes[shape]["patterns"][shapes[shape]["state"]]:
		set_cellv(Vector2(vector[0], vector[1]), 0, false, false, false, c)


func rotate_reverse_shape(shape : int):
	var dshape = shapes[shape]
	var cstate = dshape["state"]
	if cstate > 0:
		cstate -= 1
	else:
		cstate = dshape["rotations"] - 1
	
	dshape["state"] = cstate
	set_shape(shape)


func rotate_shape(shape : int):
	var shape_data = shapes[shape]
	
	if shape_data["state"] < shape_data["rotations"] - 1:
		shape_data["state"] += 1
	else:
		shape_data["state"] = 0
	
	set_shape(shape)
	
