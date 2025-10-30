extends Control

@export var band_count: int = 3
#default mbslider size
@export var control_size: Vector2 = Vector2(300, 100)
@export var slider_spacing: int = 10
var sliders: Array[ColorRect] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get the window width and use it for the control
	var window_size = get_viewport().get_visible_rect().size
	var control_width = window_size.x
	
	# Calculate the width of each rectangle to fill the control
	var total_spacing = (band_count - 1) * slider_spacing
	var available_width = control_width - total_spacing
	var slider_width = available_width / band_count
	
	for i in range(band_count):
		var slider = ColorRect.new()
		slider.color = Color(1, 1, 1, 1)
		# Enable mouse detection for hover effects
		slider.mouse_filter = Control.MOUSE_FILTER_PASS
		# Set size and position to fill the control width
		slider.size = Vector2(slider_width, control_size.y)
		slider.position = Vector2(i * (slider_width + slider_spacing), 0)
		
		# Connect mouse events for hover effect
		slider.mouse_entered.connect(_on_slider_mouse_entered.bind(slider))
		slider.mouse_exited.connect(_on_slider_mouse_exited.bind(slider))
		
		add_child(slider)
		sliders.append(slider)

# Mouse hover event handlers
func _on_slider_mouse_entered(slider: ColorRect) -> void:
	# Add blue border when mouse enters
	slider.add_theme_stylebox_override("panel", _create_border_style(Color.BLUE, 15))

func _on_slider_mouse_exited(slider: ColorRect) -> void:
	# Remove border when mouse exits
	slider.remove_theme_stylebox_override("panel")

# Helper function to create a border style
func _create_border_style(border_color: Color, border_width: int) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1, 1)  # Keep white background
	style.border_color = border_color
	style.set_border_width_all(border_width)
	return style

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
