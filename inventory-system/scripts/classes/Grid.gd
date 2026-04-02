class_name Grid

var _width: int = 0
var _height: int = 0
var _size: int = 0

var _initial_val: Variant
var _contents: Array = []


func _init(w: int, h: int, val: Variant = null) -> void:
	if w <= 0 or h <= 0:
		printerr("Dimensions must be 1x1 or greater")
	_resize(w, h)
	_initial_val = val
	fill(_initial_val)


func _to_string() -> String:
	return "Grid (%dx%d): \n" % [_width, _height]


func _resize(w: int, h: int) -> void:
	_width = w
	_height = h
	_size = _width * _height
	_contents.resize(_size)

# Public


func is_valid_vec(pos: Vector2i) -> bool:
	return is_valid(pos.x, pos.y)


func is_valid(x: int, y: int) -> bool:
	return (x >= 0 and x < _width and y >= 0 and y < _height)


func is_empty_vec(pos: Vector2i) -> bool:
	return is_empty(pos.x, pos.y)


func is_empty(x: int, y: int) -> bool:
	return get_at(x, y) == _initial_val


func set_at_vec(pos: Vector2i, val: Variant) -> void:
	set_at(pos.x, pos.y, val)


func set_at(x: int, y: int, val: Variant) -> void:
	if (not is_valid(x, y)):
		printerr("Index out of bounds.")
		return
	_contents.set(x + _width * y, val)


func get_at_vec(pos: Vector2i) -> Variant:
	return get_at(pos.x, pos.y)


func get_at(x: int, y: int) -> Variant:
	if (not is_valid(x, y)):
		printerr("Index out of bounds.")
		return null
	return _contents.get(x + _width * y)


## Returns the position of the first occurrance of `value`
func find(value: Variant) -> Vector2i:
	for i in range(_contents.size()):
		if (_contents[i] == value):
			var x: int = i % _width
			@warning_ignore("integer_division") var y: int = i / _width
			return Vector2i(x, y)
	return Vector2i(-1, -1)


func find_all(value: Variant) -> Array[Vector2i]:
	var matches: Array[Vector2i] = []
	for i in range(_contents.size()):
		if (_contents[i] == value):
			var x: int = i % _width
			@warning_ignore("integer_division") var y: int = i / _width
			matches.append(Vector2i(x, y))
	return matches


func resize(w: int, h: int) -> void:
	if (w < 0 or h < 0):
		printerr("Values must be non-negative")
		return
	_resize(w, h)


func size() -> int:
	return _size


func fill(val: Variant) -> void:
	_contents.fill(val)


func clear() -> void:
	_contents.clear()
	_contents.resize(_size)


func print_contents(verbose: bool = true) -> void:
	print("Grid (%dx%d)" % [_width, _height])
	if (verbose):
		var output: String = ""
		for i in range(_size):
			if _contents[i] == null:
				output += "null"
			else:
				output += "%s" % _contents[i]
			if ((i + 1) % _width == 0):
				output += "\n"
			else:
				output += ", "
		print(":\n" + output)


static func copy(src: Grid) -> Grid:
	var new_grid: Grid = Grid.new(src._width, src._height)
	new_grid._contents = src._contents.duplicate() # deep copy
	return new_grid
