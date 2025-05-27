class_name TShape
extends TileMap

export (int) var n := 3


export (bool) var is_I := false
export (bool) var is_ghost := false
var state_rotation : int = 0


func _ready():
	if is_ghost:
		return
	if $ColorRect and $ColorRect.visible:
		$ColorRect.color = Color(randf(), randf(), randf(), 0.25)


func set_shape(matris: Array) -> void:
	var used_cells := get_used_cells()
	if used_cells.empty():
		return

	var first_cell: Vector2 = used_cells[0]
	var cell_coord := get_cell_autotile_coord(first_cell.x, first_cell.y)

	for y in range(n):
		for x in range(n):
			if matris[y][x] > -1:
				set_cell(x, y, 0, false, false, false, cell_coord)
			else:
				set_cell(x, y, -1)


func rotate_shape(clockwise: bool = true) -> Array:
	var used_cells := get_used_cells()
	var matris: Array = []
	var cell_coord := Vector2(-1, -1)

	for y in range(n):
		var row: Array = []
		for x in range(n):
			if Vector2(x, y) in used_cells:
				row.append(get_cell(x, y))
				if cell_coord == Vector2(-1, -1):
					cell_coord = get_cell_autotile_coord(x, y)
			else:
				row.append(-1)
		matris.append(row)

	var rotated := []
	for y in range(n):
		var row: Array = []
		for x in range(n):
			row.append(-1)
		rotated.append(row)

	# Saat yönü (clockwise) döndürme
	if clockwise:
		for y in range(n):
			for x in range(n):
				rotated[x][n - 1 - y] = matris[y][x]
	else:
		# Saat yönü tersi (counter-clockwise)
		for y in range(n):
			for x in range(n):
				rotated[n - 1 - x][y] = matris[y][x]

	return rotated
