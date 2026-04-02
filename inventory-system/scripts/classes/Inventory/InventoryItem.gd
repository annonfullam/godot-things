extends TextureRect

# [] TODO: Make some kind of click anchor so it will center based on where you grabbed the piece from.
class_name InventoryItem

@export var item_data: InventoryItemData

var footprint: Array[Vector2i]
var been_placed: bool = false

var _can_be_dragged: bool = true
var _being_dragged: bool = false

var _restore_position: Vector2
var _restore_rotation: float
var _restore_footprint: Array[Vector2i]

var _manager: InventoryManager


func _ready() -> void:
	_manager = self.get_parent()
	footprint = item_data.inventory_footprint.duplicate()

	_create_debug_shape() # Comment this out for custom icons

	mouse_filter = Control.MOUSE_FILTER_STOP

	texture = item_data.icon
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	custom_minimum_size = _manager.cell_size
	size = _manager.cell_size

	pivot_offset = size / 2.0


func _create_debug_shape() -> void:
	modulate = Color(randf(), randf(), randf())

	for cell in footprint:
		if cell == Vector2i.ZERO:
			continue
		var new_texture: TextureRect = TextureRect.new()
		new_texture.texture = item_data.icon
		add_child(new_texture)
		new_texture.position = Vector2i(_manager.cell_size.x + _manager.h_separation, _manager.cell_size.y + _manager.v_separation) * cell
		new_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		new_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		new_texture.custom_minimum_size = _manager.cell_size
		new_texture.size = _manager.cell_size


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and not _being_dragged:
				_on_drag_start()
			else:
				_on_drag_end()

	elif event is InputEventMouseMotion:
		if _being_dragged:
			_on_drag()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory_rotate") and _being_dragged:
		_rotate()


func _on_drag_start() -> void:
	if not _can_be_dragged:
		return

	_restore_position = position
	_restore_rotation = rotation
	_restore_footprint = footprint.duplicate()

	# var footprint_pos: Vector2i = pos_to_footprint_pos(get_global_mouse_position())
	# pivot_offset = size / 2 + footprint_pos_to_local_pos(footprint_pos)

	_being_dragged = true
	modulate.a = 0.7

	_manager.remove_item(self)
	_manager.cur_dragged_item = self

	print("Drag started")


func _on_drag_end() -> void:
	_being_dragged = false
	modulate.a = 1.0

	_manager.place_item(self)
	_manager.cur_dragged_item = null
	print(_manager.get_contents())

	print("Drag ended")


func _on_drag() -> void:
	if not _can_be_dragged:
		return

	position = get_global_mouse_position() - pivot_offset

	# print("Dragging")


func _rotate() -> void:
	if not _can_be_dragged:
		return

	rotation = fmod(rotation + deg_to_rad(90), deg_to_rad(360))

	for i in range(footprint.size()):
		var cell: Vector2i = footprint[i]
		footprint[i] = Vector2i(-cell.y, cell.x)

	print("Rotated")

# Public

# func pos_to_footprint_pos(pos: Vector2) -> Vector2i:
# 	return Vector2i(floor((pos.x - position.x) / size.x), floor((pos.y - position.y) / size.y))

# func footprint_pos_to_local_pos(footprint_pos: Vector2i) -> Vector2:
# 	return Vector2(footprint_pos.x * size.x, footprint_pos.y * size.y)


func cancel_drag() -> void:
	position = _restore_position
	rotation = _restore_rotation
	footprint = _restore_footprint

	_being_dragged = false
	modulate.a = 1.0

	_manager.place_item(self)
	_manager.cur_dragged_item = null

	print("Cancelled drag")
