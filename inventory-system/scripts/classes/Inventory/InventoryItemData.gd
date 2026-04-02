extends Resource

class_name InventoryItemData

## Must be unique
@export var name: String
@export var description: String
@export var icon: Texture2D

@export var inventory_footprint: Array[Vector2i] = [Vector2i.ZERO]


func _to_string() -> String:
	return "Item (%s, footprint: %s)" % [name, inventory_footprint]


func get_footprint_size() -> Vector2i:
	var max_x: int = 0
	var max_y: int = 0
	for cell in inventory_footprint:
		max_x = max(max_x, cell.x)
		max_y = max(max_y, cell.y)
	return Vector2i(max_x + 1, max_y + 1)
