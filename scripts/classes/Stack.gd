class_name Stack

var _contents: Array = []


func _to_string() -> String:
	return "Stack (%d, top: %s) \n" % [size(), top()]

# Public


func size() -> int:
	return _contents.size()


func is_empty() -> bool:
	return size() == 0


func top() -> Variant:
	if (size() == 0):
		return null
	return _contents[size() - 1]


func push(val: Variant) -> void:
	_contents.push_back(val)


func pop() -> Variant:
	if (size() == 0):
		printerr("There are no elements in the stack.")
		return
	return _contents.pop_back()


func clear() -> void:
	_contents.clear()
