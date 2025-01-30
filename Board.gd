extends TileMap


const WIDTH  = 10
const HEIGHT = 20


onready var timer_fall = $ShapeFall

# SHAPES
onready var shape_scene = preload("res://Shape.tscn")
#onready var denek = $Denek

onready var shape_scenes = ["res://Shapes/ShapeI.tscn", "res://Shapes/ShapeJ.tscn", "res://Shapes/ShapeL.tscn", "res://Shapes/ShapeO.tscn", "res://Shapes/ShapeS.tscn", "res://Shapes/ShapeT.tscn", "res://Shapes/ShapeZ.tscn"]

var shapes : Array = []
var shape_current : TShape
var shape_position : Vector2 = Vector2.ONE
var shape_direction : Vector2 = Vector2.DOWN
var shape_cells : PoolVector2Array
var shape_index : int


var shape_spawn_position : Vector2 = Vector2(5, 1)


func _ready():
	randomize()
	
	for i in range(shape_scenes.size()):
		shape_scenes[i] = load(shape_scenes[i])
	
	shape_spawn()


func _input(event):
	if event is InputEventKey:
		if event.pressed:
			match event.scancode:
				KEY_DOWN:
					timer_fall.wait_time = 0.2
				KEY_RIGHT:
					shape_direction = Vector2.RIGHT
					shape_move(shape_current, shape_direction)
				KEY_LEFT:
					shape_direction = Vector2.LEFT
					shape_move(shape_current, shape_direction)
				KEY_UP:
					shape_rotate()
				KEY_K:
					pass
#					denek_rotate()
		
		else: # released
			match event.scancode:
				KEY_DOWN:
					timer_fall.wait_time = 0.5


func shape_spawn():
	# secilenlerin hepsi ayni cunku ready icinde oyle tanimladim.
	shape_index = get_random_shape()
	
#	shape_current = shape_scene.instance()
	shape_current = shape_scenes[shape_index].instance()
	
	# set_shape burada cagirilacak.
#	shape_current.set_shape(shape_index)
	
	add_child(shape_current)
	
	shape_position = shape_spawn_position
	shape_current.position = map_to_world(shape_spawn_position)


func get_random_shape():
	return randi() % shape_scenes.size()
#	return randi() % TShape.SHAPE.size()


# Sekli oyun tahtasina yerlestirdikten sonra
# hangi satirlarda islem yapildigini dondurur.
func shape_commit(shape : TShape) -> PoolIntArray:
	var shape_used_cells = shape.get_used_cells()
	var lines : PoolIntArray = []
	
	for cell_local in shape_used_cells:
		var cell_global : Vector2 = cell_local + shape_position
		
		if not cell_global.y in lines:
			lines.append(cell_global.y)
		
		set_cellv(cell_global, 0)
	
	shape_current.queue_free()
	
	return lines


func pop_lines(lines : PoolIntArray):
	lines.sort()
	
	var counter_full_lines : int = 0
	var is_full_line : bool = false
	
	for i in range(HEIGHT, 0, -1):
		if i in lines:
			counter_full_lines += 1
			is_full_line = true
		
		for j in range(1, WIDTH + 1):
			if is_full_line:
				set_cell(j, i, -1)
			
			elif get_cell(j, i) > -1:
				set_cell(j, i, -1)
				set_cell(j, i+counter_full_lines, 0)
		
		is_full_line = false


func check_lines(lines : PoolIntArray) -> PoolIntArray:
	var lines_full : PoolIntArray = []
	
	for l in lines:
		for i in range(1, WIDTH + 1):
			if get_cellv(Vector2(i, l)) < 0:
				break
			
			if i == WIDTH:
				lines_full.append(l)
	
	return lines_full


func shape_move(shape : TShape, direction : Vector2):
	var new_pos = shape_position + direction
	if shape_is_collide(shape_current, new_pos, direction):
		if direction == Vector2.DOWN:
			var lines : PoolIntArray = shape_commit(shape_current)
			lines = check_lines(lines)
			if not lines.empty():
				pop_lines(lines)
			
			shape_spawn()
	else:
		shape_set_position(shape_current, new_pos)
	
	shape_direction = Vector2.ZERO


func shape_is_collide(shape : TShape, new_pos : Vector2, direction : Vector2, is_rotated : bool = false):
	if not shape_current:
		return
	
	var is_collision : bool = false
	
	var shape_cells_local = shape_current.get_used_cells()
	for cell in shape_cells_local:
		var collision_cell : Vector2 = new_pos + cell
		# Kendi hucreleriyle cakisma testi
		# Eger sekil dondurulmus ise kendi hucrelerini kontrol edecek.
		if is_rotated or not (cell + direction) in shape_cells_local:
			if get_cellv(collision_cell) >= 0:
				is_collision = true
	
	return is_collision


func shape_set_position(shape : TShape, new_pos : Vector2):
	if not shape_current:
		return
	
	shape_position = new_pos
	shape_current.position = map_to_world(shape_position)


func shape_rotate():
	# sekli cevir
#	shape_current.rotate_shape(shape_index)
	shape_current.rotate_shape()
	
	# cevrilmis seklin hucrelerinde cakisma varsa
	# eski haline dondur
#	if shape_is_collide(shape_current, shape_position, Vector2.ZERO, true):
#		shape_current.rotate_reverse_shape(shape_index)


func _on_ShapeFall_timeout():
	if shape_current:
		shape_move(shape_current, Vector2.DOWN)
