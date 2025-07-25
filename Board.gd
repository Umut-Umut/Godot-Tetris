class_name Board
extends TileMap


const WIDTH  = 10
const HEIGHT = 20


onready var timer_fall = $ShapeFall
onready var timer_lock = $LockDown

# SHAPES
onready var shape_scene = preload("res://Shape.tscn")
#onready var denek = $Denek

# PackedScenes will load in _ready
onready var shape_scenes = [
	"res://Shapes/ShapeI.tscn", 
	"res://Shapes/ShapeJ.tscn", 
	"res://Shapes/ShapeL.tscn", 
	"res://Shapes/ShapeO.tscn", 
	"res://Shapes/ShapeS.tscn", 
	"res://Shapes/ShapeT.tscn", 
	"res://Shapes/ShapeZ.tscn"
	]
onready var shape_ghost = $TShapeGhost
onready var hold_area : Position2D = $HoldArea

# Permutated index of shape_scenes
var shapes : Array = []
# Next permutation of shapes
var shapes_next : Array = []
var shape_counter : int = 0
var shape_current : TShape = null
var shape_position : Vector2 = Vector2.ONE
var shape_direction : Vector2 = Vector2.DOWN
var shape_cells : PoolVector2Array
var shape_index : int
#var shape_hold_index : int = -1

var shape_spawn_position : Vector2 = Vector2(5, 0)
# Dunyanin en mantiksiz cozumu
#var hold_area_size : Vector2 = Vector2(3, 3)

var shape_hold : TShape = null
var is_shape_comit : bool = true
#var holded_index : int = -1

var next_queue : Array = []
onready var next_que_poses = $NextQuePoses.get_children()

var shape_ghost_pos : Vector2 = shape_spawn_position


const SRS_KICK_TABLE = [
	{ "cw": [Vector2(0, 0), Vector2(-1, 0), Vector2(-1, 1), Vector2(0, -2), Vector2(-1, -2)],
	  "ccw": [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, -2), Vector2(1, -2)] }, # 0 <-> 1

	{ "cw": [Vector2(0, 0), Vector2(1, 0), Vector2(1, -1), Vector2(0, 2), Vector2(1, 2)],
	  "ccw": [Vector2(0, 0), Vector2(1, 0), Vector2(1, -1), Vector2(0, 2), Vector2(1, 2)] }, # 1 <-> 2

	{ "cw": [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, -2), Vector2(1, -2)],
	  "ccw": [Vector2(0, 0), Vector2(-1, 0), Vector2(-1, 1), Vector2(0, -2), Vector2(-1, -2)] }, # 2 <-> 3

	{ "cw": [Vector2(0, 0), Vector2(-1, 0), Vector2(-1, -1), Vector2(0, 2), Vector2(-1, 2)],
	  "ccw": [Vector2(0, 0), Vector2(-1, 0), Vector2(-1, -1), Vector2(0, 2), Vector2(-1, 2)] } # 3 <-> 0
]

const SRS_KICK_TABLE_I = [
	{ "cw": [Vector2(0, 0), Vector2(-2, 0), Vector2(1, 0), Vector2(-2, -1), Vector2(1, 2)],
	  "ccw": [Vector2(0, 0), Vector2(-1, 0), Vector2(2, 0), Vector2(-1, 2), Vector2(2, -1)] }, # 0 <-> 1

	{ "cw": [Vector2(0, 0), Vector2(-1, 0), Vector2(2, 0), Vector2(-1, 2), Vector2(2, -1)],
	  "ccw": [Vector2(0, 0), Vector2(2, 0), Vector2(-1, 0), Vector2(2, 1), Vector2(-1, -2)] }, # 1 <-> 2

	{ "cw": [Vector2(0, 0), Vector2(2, 0), Vector2(-1, 0), Vector2(2, 1), Vector2(-1, -2)],
	  "ccw": [Vector2(0, 0), Vector2(1, 0), Vector2(-2, 0), Vector2(1, -2), Vector2(-2, 1)] }, # 2 <-> 3

	{ "cw": [Vector2(0, 0), Vector2(1, 0), Vector2(-2, 0), Vector2(1, -2), Vector2(-2, 1)],
	  "ccw": [Vector2(0, 0), Vector2(-2, 0), Vector2(1, 0), Vector2(-2, -1), Vector2(1, 2)] } # 3 <-> 0
]


# NextQueue icine 3 sekli yerlestir.
# Bu sekilleri pos2d lere yerlestir.
# spawn dan sonra NextQueue pop sonra siradaki sekli append

func _ready():
	randomize()
	
	for i in range(shape_scenes.size()):
		
		shape_scenes[i] = load(shape_scenes[i])
		# Index of Packs
		shapes.append(i)
		# Copy of shapes
		shapes_next.append(i)
	
	shapes.shuffle()
	shapes_next.shuffle()
	
	shape_spawn()
	update_ghost()


var is_down : bool = false
func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if not event.is_echo():
				match event.scancode:
					KEY_UP:
						shape_rotate()
						update_ghost(true)
					KEY_X:
						shape_rotate()
						update_ghost(true)
					KEY_Z:
						shape_rotate(false)
						update_ghost(true)
			match event.scancode:
				KEY_DOWN:
					timer_fall.wait_time = 0.025
					if not is_down:
						timer_fall.start()
					
					is_down = true
				KEY_RIGHT:
					shape_direction = Vector2.RIGHT
					shape_move(shape_direction)
					update_ghost()
				KEY_LEFT:
					shape_direction = Vector2.LEFT
					shape_move(shape_direction)
					update_ghost()
				KEY_SPACE:
					if not event.echo:
						hard_drop()
				KEY_C:
					if is_shape_comit:
						var temp : TShape = null
						if shape_hold:
							shape_hold.position = shape_spawn_position * self.cell_size
							shape_position = shape_spawn_position
							temp = shape_current
							shape_current = shape_hold
						if temp:
							shape_hold = temp
							shape_hold.position = hold_area.position
							shape_hold.set_default()
						else:
							shape_current.position = hold_area.position
							shape_hold = shape_current
							shape_spawn()
							
#						shape_hold = shape_scenes[shape_index].instance()
#						add_child(shape_hold)
#						shape_hold.position = hold_area.position
						
						is_shape_comit = false
						update_ghost(true)
#			update_ghost()
		
		else: # released
			match event.scancode:
				KEY_DOWN:
					timer_fall.wait_time = 0.5
					is_down = false


func hard_drop():
	while not shape_move(Vector2.DOWN):
		pass
	shape_lock()


func update_ghost(is_rotated : bool = false):
	# clear and update cells
	if is_rotated or shape_ghost.get_used_cells().empty():
		shape_ghost.clear()
		for cell in shape_current.get_used_cells():
			shape_ghost.set_cellv(cell, 0)
	
#	shape_ghost.position.x = shape_current.position.x
	shape_ghost_pos = shape_position
	shape_ghost.position = map_to_world(shape_position)
	
	for i in range(HEIGHT):
		if shape_move(Vector2.DOWN, true):
			break
	
	shape_ghost.n = shape_current.n
#	shape_ghost.is_I = shape_current.is_I
#	shape_ghost.position.x = shape_current.position.x
	
#	shape_ghost.position.y += self.cell_size.y * (shape_current.n + 1)
#
#	if shape_ghost.get_used_cells().empty():
#		return


#func set_hold_area(shape : TShape):
#	if not shape:
#		return
#
#	var cells = shape.get_used_cells()
#	if cells.empty():
#		return
#
#	var first_cell : Vector2 = cells[0]
#	var cell_coord = shape.get_cell_autotile_coord(first_cell.x, first_cell.y)
#	var shape_area_size : Vector2 = Vector2.ONE * shape.n
#	var pos : Vector2
#
#	hold_area.clear()
#	for cell in cells:
##		pos = cell + (hold_area_size - shape_area_size)
#		hold_area.set_cellv(
#			cell,
#			0, false, false, false, cell_coord)
#
##	holded_index = shape_index
#
#	shape.queue_free()


func shape_spawn():
#	if shape_current:
#		shape_current.queue_free()
	# secilenlerin hepsi ayni cunku ready icinde oyle tanimladim.
#	if index >= 0:
#		shape_index = index
#	else:
#		shape_index = get_random_shape()
	
	shape_index = get_random_shape()
#	shape_current = shape_scene.instance()
	shape_current = shape_scenes[shape_index].instance()
	
	update_next_que()
	
	# set_shape burada cagirilacak.
#	shape_current.set_shape(shape_index)
#	set_hold_area(shape_current)
	
	shape_position = shape_spawn_position
	shape_ghost_pos = shape_spawn_position
	shape_current.position = map_to_world(shape_spawn_position)
	
	add_child(shape_current)



func get_random_shape():
	# Karistirilmis olan sekiller listesinden sirasiyla sekilleri geri dondurur.
	var s : int = shapes[shape_counter]
	shape_counter += 1
	if shape_counter == shape_scenes.size():
		shape_counter = 0
		# next_queue işleminde kullanılmak üzere bir sonraki permütasyon
		# oluşturuluyor.
		shapes = shapes_next.duplicate()
		shapes_next.shuffle()
	
	return s
#	return randi() % shape_scenes.size()
#	return randi() % TShape.SHAPE.size()

var next_limit = 5
var is_next_limit_fixed = false
func update_next_que():
	# Siniri astigi icin next_limit sabitlendiyse, isaretle ve surekli bakma.
	if is_next_limit_fixed:
		pass
	elif next_limit > next_que_poses.size() or next_limit > shapes.size():
		next_limit = min(next_que_poses.size(), shapes.size())
		is_next_limit_fixed = true
	
	# Eger, next_queue bos ise siradaki sekilleri olustur ve ekle.
	if next_queue.empty():
		var next_pos_count : int = 0
		for i in range(shape_counter, shape_counter + next_limit):
			var s = shape_scenes[shapes[i]].instance()
			next_queue.append(s)
			s.position = next_que_poses[next_pos_count].position
			next_pos_count += 1
			
			add_child(s)
	else: # Siranin en basindakini sil ve siradaklari one kaydir.
		next_queue.pop_front().queue_free()
		var next = (shape_counter + (next_limit - 1))
		var shape = null
		# Eğer mevcut şekilden üç sonraki şeklin indeksi sınırı aşıyorsa,
		# "shapes_next"den şekli alıyor.
		if next < shapes.size():
			shape = shape_scenes[shapes[next]].instance()
		else:
			shape = shape_scenes[shapes_next[next % shapes.size()]].instance()
		
		next_queue.append(shape)
		add_child(shape)
		
		
		for i in range(next_limit):
			if i < next_queue.size():
				next_queue[i].position = next_que_poses[i].position


# Sekli oyun tahtasina yerlestirdikten sonra
# hangi satirlarda islem yapildigini dondurur.
func shape_commit(shape : TShape) -> PoolIntArray:
	var shape_used_cells = shape.get_used_cells()
	var lines : PoolIntArray = []
	
	var tile_coord = shape.get_cell_autotile_coord(shape_used_cells[0].x, shape_used_cells[0].y)
	
	for cell_local in shape_used_cells:
		var cell_global : Vector2 = cell_local + shape_position
		
		if not cell_global.y in lines:
			lines.append(cell_global.y)
		
		set_cellv(cell_global, 0, false, false, false, tile_coord)
	
	shape_current.queue_free()
	
	is_shape_comit = true
	
	return lines


#func pop_lines(lines : PoolIntArray):
#	lines.sort()
#
#	var counter_full_lines : int = 0
#	var is_full_line : bool = false
#
#
#	for i in range(HEIGHT, 0, -1):
#		if i in lines:
#			counter_full_lines += 1
#			is_full_line = true
#
#		for j in range(1, WIDTH + 1):
#			if is_full_line:
#				set_cell(j, i, -1)
#
#			elif get_cell(j, i) > -1:
#				set_cell(j, i, -1)
#				set_cell(j, i+counter_full_lines, 0)
#
#		is_full_line = false
func pop_lines(lines: PoolIntArray):
	# Optimized with ChatGPT.
	
	lines.sort()
	
	var counter_full_lines := 0
	
	for i in range(HEIGHT, 0, -1):
		if i in lines:
			counter_full_lines += 1
			for j in range(1, WIDTH + 1):
				set_cell(j, i, -1)  # Satırı temizle
		elif counter_full_lines > 0:
			for j in range(1, WIDTH + 1):
				set_cell(j, i + counter_full_lines, get_cell(j, i),
				false, 
				false,
				false,
				get_cell_autotile_coord(j, i))
				set_cell(j, i, -1)  # Önceki hücreyi temizle


func check_lines(lines : PoolIntArray) -> PoolIntArray:
	var lines_full : PoolIntArray = []
	
	for l in lines:
		for i in range(1, WIDTH + 1):
			if get_cellv(Vector2(i, l)) < 0:
				break
			
			if i == WIDTH:
				lines_full.append(l)
	
	return lines_full

# shape : TShape gereksiz
#func shape_move(shape : TShape, direction : Vector2, is_rotated : bool = false, is_ghost : bool = false):
func shape_move(direction : Vector2, is_ghost : bool = false, is_rotated : bool = false):
	if is_ghost:
		if shape_is_collide(shape_ghost, shape_ghost_pos, direction):
			return true
		else:
			shape_ghost_pos += direction
			shape_ghost.position = map_to_world(shape_ghost_pos)
				
	elif not is_rotated and shape_is_collide(shape_current, shape_position, direction):
		if direction == Vector2.DOWN and timer_lock.is_stopped():
			timer_lock.start()
			return true
	else:
		if direction == Vector2.DOWN and not timer_lock.is_stopped():
			timer_lock.stop()
		
		shape_set_position(shape_current, shape_position + direction)
#	elif not is_rotated and shape_is_collide(shape_current, shape_position, direction):
#		if direction == Vector2.DOWN and timer_lock.is_stopped():
#			timer_lock.start()
#			print("STarted")
#			return true
#	else:
#		if shape_position.y == 19:
#			print("Bu nasil bir hatadir dermani yoktur")
#		if not shape_is_collide(shape_current, shape_position, Vector2.DOWN):
#			if not timer_lock.is_stopped():
#				timer_lock.stop()
#				print("Stopped")
#		shape_set_position(shape_current, shape_position + direction)
	
	shape_direction = Vector2.ZERO
	
	return false


#func shape_is_collide(shape : TShape, shape_position : Vector2, direction : Vector2, is_rotated : bool = false, is_lock_check : bool = false):
func shape_is_collide(shape : TShape, pos : Vector2, direction : Vector2):
	# is_rotated parametresi kullanilmiyor gibi
	# shape_position gereksiz. Mevcut pozisyon ve yon kullanmayi dene
	
	if direction == Vector2.ZERO:
		return false
	
	if not shape:
		return false
	
	var is_collision : bool = false
	
	var shape_cells_local = shape.get_used_cells()
	for cell in shape_cells_local:
		var collision_cell : Vector2 = pos + cell + direction
#		var collision_cell : Vector2 = shape_position + cell
		# Kendi hucreleriyle cakisma testi
		# Eger sekil dondurulmus ise kendi hucrelerini kontrol edecek.
		if not (cell + direction) in shape_cells_local:
#		if is_rotated or not (cell + direction) in shape_cells_local:
			if get_cellv(collision_cell) >= 0:
				is_collision = true
				break
#			if is_lock_check:
#				if get_cellv(collision_cell + direction):
#					is_collision = true
#					break
#			else:
#				if get_cellv(collision_cell) >= 0:
#					is_collision = true
#					break
	
	return is_collision


func matris_is_collide(matris : Array, shape_position : Vector2) -> bool:
	if matris.empty():
		return true
	
	var n = matris.size()
	
	# shape_position; seklin tahta uzerindeki bir sonraki koordinati
	for y in range(n):
		for x in range(n):
			if matris[y][x] == -1:
				continue
			
			var global_pos : Vector2 = Vector2(x, y) + shape_position
			if get_cellv(global_pos) >= 0:
				return true
	
	return false

# Bu fonksiyon da sikintili. Gereksiz parametreler ve global erisim var.
func shape_set_position(shape : TShape, new_pos : Vector2):
	if not shape_current:
		return
	
	shape_position = new_pos
	shape_current.position = map_to_world(shape_position)


#func shape_rotate(is_clockwise : bool = true):
##	sekli cevir
##	shape_current.rotate_shape(shape_index)
#	var rotated_matris : Array = shape_current.rotate_shape(is_clockwise)
#	var is_rotated : bool = false
#	var n = rotated_matris.size()
#
#	var kick_table = SRS_KICK_TABLE[shape_current.state_rotation]
#	if shape_current.is_I:
#		kick_table = SRS_KICK_TABLE_I[shape_current.state_rotation]
#
#	if matris_is_collide(rotated_matris, shape_position):
#		for kick in kick_table:
#			if matris_is_collide(rotated_matris, shape_position + kick):
#				pass
#			else:
#				is_rotated = true
#				shape_move(kick, false, is_rotated)
#				shape_current.set_shape(rotated_matris)
#				break
#	else:
#		shape_current.set_shape(rotated_matris)
#		is_rotated = true
#
#	# Kick table gecis durumu icin
#	if is_rotated:
#		shape_current.state_rotation += 1
#		if shape_current.state_rotation == 4:
#			shape_current.state_rotation = 0
#
#	# cevrilmis seklin hucrelerinde cakisma varsa
#	# eski haline dondur
##	if shape_is_collide(shape_current, shape_position, Vector2.ZERO, true):
##		shape_current.rotate_reverse_shape(shape_index)

func shape_rotate(is_clockwise: bool = true):
	var rotated = shape_current.rotate_shape(is_clockwise)
	var new_rotation = (shape_current.state_rotation + (1 if is_clockwise else -1)) % 4
	if new_rotation < 0: new_rotation += 4

	var rotated_success = false
	var kick_table = SRS_KICK_TABLE
	if shape_current.is_I:
		kick_table = SRS_KICK_TABLE_I

	var kicks = kick_table[shape_current.state_rotation]["cw" if is_clockwise else "ccw"]

	if matris_is_collide(rotated, shape_position):
		for kick in kicks:
			if not matris_is_collide(rotated, shape_position + kick):
				shape_move(kick, false, true)
				shape_current.set_shape(rotated)
				shape_current.state_rotation = new_rotation
				rotated_success = true
				break
	else:
		shape_current.set_shape(rotated)
		shape_current.state_rotation = new_rotation
		rotated_success = true



func shape_lock():
	var lines : PoolIntArray = shape_commit(shape_current)
	lines = check_lines(lines)
	if not lines.empty():
		pop_lines(lines)

	shape_spawn()
	shape_ghost.clear()
	update_ghost()

	shape_direction = Vector2.ZERO


func _on_ShapeFall_timeout():
	if shape_current:
		shape_move(Vector2.DOWN)
#		update_ghost()


func _on_LockDown_timeout():
	if not shape_is_collide(shape_current, shape_position, Vector2.DOWN):
		timer_lock.start()
		return
	
	shape_lock()
#	var lines : PoolIntArray = shape_commit(shape_current)
#	lines = check_lines(lines)
#	if not lines.empty():
#		pop_lines(lines)
#
#	shape_spawn()
#	shape_ghost.clear()
#	update_ghost()
#
#	shape_direction = Vector2.ZERO
