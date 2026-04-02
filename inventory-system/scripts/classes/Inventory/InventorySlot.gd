extends TextureRect

class_name InventorySlot

func set_highlight(color: Color) -> void:
	self_modulate = color


func clear_highlight() -> void:
	self_modulate = Color.WHITE
