extends Control

class_name InventoryManager

@export var grid_size: Vector2i

@export var cell_size: Vector2i
@export var cell_texture: Texture2D

@export var h_separation: int
@export var v_separation: int

var data: Grid
var cur_dragged_item: InventoryItem = null

var _grid_container: GridContainer


func _ready() -> void:
	_grid_container = self.find_child("GridContainer")
	_grid_container.columns = grid_size.x
	_grid_container.add_theme_constant_override("h_separation", h_separation)
	_grid_container.add_theme_constant_override("v_separation", v_separation)

	data = Grid.new(grid_size.x, grid_size.y, null)

	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var new_cell: InventorySlot = InventorySlot.new()
			new_cell.texture = cell_texture
			new_cell.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			new_cell.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			new_cell.custom_minimum_size = cell_size

			_grid_container.add_child(new_cell)


func _process(_delta: float) -> void:
	for child in _grid_container.get_children():
		if child is InventorySlot:
			child.clear_highlight()

	if cur_dragged_item:
		_update_ui_preview()


func _update_ui_preview() -> void:
	var grid_pos: Vector2i = get_grid_coords_at_pos(cur_dragged_item.global_position)

	var can_fit: bool = can_item_fit(cur_dragged_item)
	var highlight_color: Color = Color.GREEN if can_fit else Color.RED
	highlight_color.a = 0.5

	for cell in cur_dragged_item.footprint:
		var target: Vector2i = grid_pos + cell
		if data.is_valid_vec(target):
			var slot_index: int = target.y * grid_size.x + target.x
			var slot: InventorySlot = _grid_container.get_child(slot_index) as InventorySlot
			slot.set_highlight(highlight_color)

# Public


func can_item_fit(item: InventoryItem) -> bool:
	var grid_pos: Vector2i = get_grid_coords_at_pos(item.global_position)

	for cell in item.footprint:
		var target: Vector2i = grid_pos + cell
		if not data.is_valid_vec(target) or not data.is_empty_vec(target):
			return false
	return true


func place_item(item: InventoryItem) -> void:
	var grid_pos: Vector2i = get_grid_coords_at_pos(item.global_position)

	if not can_item_fit(item):
		item.cancel_drag()
		return

	item.grid_anchor = grid_pos
	for cell in item.footprint:
		data.set_at_vec(grid_pos + cell, item.item_data.id)

	item.global_position = get_pixel_pos_at_coords(grid_pos)


## This function does not check whether or not the cells belong to the actual item
## so you must make sure you are passing in the right footprint!
func remove_item(item: InventoryItem) -> void:
	if item.grid_anchor == Vector2i(-1, -1):
		return

	for cell in item.footprint:
		var target: Vector2i = item.grid_anchor + cell
		if not data.is_valid_vec(target):
			push_error("Index out of bounds")
			return

	for cell in item.footprint:
		var target: Vector2i = item.grid_anchor + cell
		data.set_at_vec(target, null)

	item.grid_anchor = Vector2i(-1, -1)


func get_grid_coords_at_pos(pixel_pos: Vector2) -> Vector2i:
	var local_pos: Vector2 = pixel_pos - global_position

	var step_x: float = cell_size.x + h_separation
	var step_y: float = cell_size.y + v_separation

	return Vector2i(round(local_pos.x / step_x), round(local_pos.y / step_y))


func get_pixel_pos_at_coords(coords: Vector2i) -> Vector2:
	return global_position + Vector2(coords.x * (cell_size.x + h_separation), coords.y * (cell_size.y + v_separation))
