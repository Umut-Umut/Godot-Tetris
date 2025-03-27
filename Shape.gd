class_name TShape
extends TileMap


export (int) var n = 3 


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
	I,
	#S,
	#T
}


var shapes : Dictionary = {
	 SHAPE.C : {"color" : 1, "state" : 0, "rotations" : 1, "patterns" : [
		[[0, 0], [0, 1], [1, 0], [1, 1]],
		]},
	SHAPE.L : {"color" : 3, "state" : 0, "rotations" : 3, "patterns" : [
		[[0, 0], [0, 1], [0, 2], [1, 2]],
		[[0, 2], [1, 2], [2, 2], [2, 1]],
		[[2, 0], [2, 1], [2, 2], [1, 2]]
		]},
	SHAPE.I : {"color" : 2, "state" : 0, "rotations" : 2, "patterns" : [
		[[0, 2], [1, 2], [2, 2], [3, 2]],
		[[2, 0], [2, 1], [2, 2], [2, 3]]
	]}
}


export (bool) var is_I = false
var state_rotation : int = 0


func _ready():
	if find_node("ColorRect"):
		if $ColorRect.visible:
			$ColorRect.color = Color(randf(), randf(), randf(), 0.25)


#func set_shape(shape : int):
#	clear()
#
#	var c : Vector2 = Vector2(shapes[shape]["color"], 0)
#	for vector in shapes[shape]["patterns"][shapes[shape]["state"]]:
#		set_cellv(Vector2(vector[0], vector[1]), 0, false, false, false, c)
func set_shape(matris : Array):
	var used_cells = get_used_cells()
	if used_cells.empty():
		return
	
	var first_cell : Vector2 = used_cells[0]
	var cell_coord = get_cell_autotile_coord(first_cell.x, first_cell.y)
	
	for y in range(n):
		for x in range(n):
			if matris[y][x] > -1:
				set_cell(x, y, 0, false, false, false , cell_coord)
			else:
				set_cell(x, y, -1)


#func rotate_reverse_shape(shape : int):
#	var dshape = shapes[shape]
#	var cstate = dshape["state"]
#	if cstate > 0:
#		cstate -= 1
#	else:
#		cstate = dshape["rotations"] - 1
#
#	dshape["state"] = cstate
#	set_shape(shape)


#func rotate_shape(shape : int):
func rotate_shape() -> Array:
	var used_cells = get_used_cells()
	var matris = []
	var rotated = []
	var cell_coord : Vector2 = Vector2(-1, -1)
	
	for y in range(n):
		var temp = []
		for x in range(n):
			if Vector2(x, y) in used_cells:
				temp.append(get_cell(x, y))
				if cell_coord == Vector2(-1, -1):
					cell_coord = get_cell_autotile_coord(x, y)
			else:
				temp.append(-1)
		
		matris.append(temp)
	
	rotated = matris.duplicate(true)
	for r in rotated:
		r.fill(-1)
	
	for y in range(n):
		for x in range(n):
			rotated[x][n - y - 1] = matris[y][x]
	
	return rotated
#	for y in range(n):
#		for x in range(n):
#			if rotated[y][x] > -1:
#				set_cell(x, y, 0, false, false, false , cell_coord)
#			else:
#				set_cell(x, y, -1)
