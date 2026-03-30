extends TextureRect

class_name InventoryItem

@export var item_data: InventoryItemData

var footprint: Array[Vector2i]
var grid_anchor: Vector2i = Vector2i(-1, -1)

var _can_be_dragged: bool = true
var _being_dragged: bool = false
var _restore_position: Vector2
var _restore_rotation: float

var _manager: InventoryManager


func _ready() -> void:
	_manager = self.get_parent()
	footprint = item_data.inventory_footprint

	mouse_filter = Control.MOUSE_FILTER_STOP
	texture = item_data.icon
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	custom_minimum_size = _manager.cell_size

	size = _manager.cell_size
	pivot_offset = size / 2.0


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

	_being_dragged = true
	_restore_position = global_position

	modulate.a = 0.7

	_manager.remove_item(self)
	_manager.cur_dragged_item = self

	print("Drag started")


func _on_drag_end() -> void:
	_being_dragged = false

	modulate.a = 1.0

	if _manager.can_item_fit(self):
		_manager.place_item(self)
	_manager.cur_dragged_item = null

	print("Drag ended")


func _on_drag() -> void:
	if not _can_be_dragged:
		return

	global_position = get_global_mouse_position() - pivot_offset.rotated(rotation)

	# print("Dragging")


func _rotate() -> void:
	if not _can_be_dragged:
		return

	rotation += deg_to_rad(90)

	for i in range(footprint.size()):
		var cell: Vector2i = footprint[i]
		footprint[i] = Vector2i(-cell.y, cell.x)

	print("Rotated")

# Public


func cancel_drag() -> void:
	_being_dragged = false

	global_position = _restore_position
	rotation = _restore_rotation

	print("Cancelled drag")
