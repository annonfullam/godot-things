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
var _contents: Dictionary[String, int] = { }


func _ready() -> void:
	data = Grid.new(grid_size.x, grid_size.y, null)

	_grid_container = self.find_child("GridContainer")
	_grid_container.columns = grid_size.x
	_grid_container.add_theme_constant_override("h_separation", h_separation)
	_grid_container.add_theme_constant_override("v_separation", v_separation)

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

	for y in range(grid_size.y):
		for x in range(grid_size.x):
			if not data.is_empty_vec(Vector2i(x, y)):
				_grid_container.get_child(y * grid_size.x + x).set_highlight(Color.BLACK)

	if cur_dragged_item:
		var can_fit: bool = can_item_fit(cur_dragged_item)
		var highlight_color: Color = Color.GREEN if can_fit else Color.RED
		var grid_pos: Vector2i = _screen_pos_to_grid_pos(cur_dragged_item.position)
		for cell in cur_dragged_item.footprint:
			var target: Vector2i = grid_pos + cell
			if data.is_valid_vec(target):
				var slot_index: int = target.y * grid_size.x + target.x
				var slot: InventorySlot = _grid_container.get_child(slot_index) as InventorySlot
				slot.set_highlight(highlight_color)


func _screen_pos_to_grid_pos(screen_pos: Vector2) -> Vector2i:
	var local_pos: Vector2 = screen_pos - global_position
	var step_x: float = cell_size.x + h_separation
	var step_y: float = cell_size.y + v_separation
	return Vector2i(round(local_pos.x / step_x), round(local_pos.y / step_y))


func _grid_pos_to_screen_pos(grid_pos: Vector2i) -> Vector2:
	var step_x: float = cell_size.x + h_separation
	var step_y: float = cell_size.y + v_separation
	return Vector2(grid_pos.x * step_x, grid_pos.y * step_y) + global_position

# Public


func can_item_fit(item: InventoryItem) -> bool:
	var grid_pos: Vector2i = _screen_pos_to_grid_pos(item.position)

	for cell in item.footprint:
		var target: Vector2i = grid_pos + cell
		if not data.is_valid_vec(target) or not data.is_empty_vec(target):
			return false
	return true


func place_item(item: InventoryItem) -> void:
	if not can_item_fit(item):
		if item.been_placed: # to prevent infinite recursion
			item.cancel_drag()
		return

	var grid_pos: Vector2i = _screen_pos_to_grid_pos(item.position)
	for cell in item.footprint:
		data.set_at_vec(grid_pos + cell, item.item_data.name)

	item.position = _grid_pos_to_screen_pos(grid_pos)
	item.been_placed = true

	if _contents.has(item.item_data.name):
		_contents[item.item_data.name] += 1
	else:
		_contents[item.item_data.name] = 1


func remove_item(item: InventoryItem) -> void:
	var grid_pos: Vector2i = _screen_pos_to_grid_pos(item.position)

	for cell in item.footprint:
		var target: Vector2i = grid_pos + cell
		if not data.is_valid_vec(target):
			push_error("Index out of bounds")
			return

	for cell in item.footprint:
		var target: Vector2i = grid_pos + cell
		data.set_at_vec(target, null)

	if _contents.has(item.item_data.name):
		_contents[item.item_data.name] -= 1
	else:
		push_error("You just removed an item that wasn't in the inventory!")


func get_contents() -> Dictionary[String, int]:
	return _contents
