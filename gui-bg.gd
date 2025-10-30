extends ColorRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# set height to fill parent window
	size.y = get_viewport().get_visible_rect().size.y
