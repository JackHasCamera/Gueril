extends TextureRect

var is_dragging = false
var drag_offset = Vector2()
var zoom_step = 1.1  # 10% zoom increment for smoother zooming
var min_zoom = 0.1
var max_zoom = 100.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Enable mouse detection for drag functionality
	mouse_filter = Control.MOUSE_FILTER_PASS
	# Make sure this node can receive input
	set_process_input(true)
	set_process_unhandled_input(true)

# Handle keyboard input globally
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key_event = event as InputEventKey
		if key_event.pressed:
			# use unicode codepoints to detect literal '[' and ']'
			if key_event.unicode == ord('['):
				print("[ key pressed")
				zoom_out()
			elif key_event.unicode == ord(']'):
				print("] key pressed")
				zoom_in()

# Handle mouse wheel events with unhandled_input for better reliability
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.pressed:  # Only handle press events
			if mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
				print("Mouse wheel up detected")
				zoom_in()
				get_viewport().set_input_as_handled()  # Consume the event
			elif mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				print("Mouse wheel down detected")
				zoom_out()
				get_viewport().set_input_as_handled()  # Consume the event

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		
		# Start dragging on left mouse button press
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_event.pressed:
				is_dragging = true
				# Store the offset between mouse position and node position
				drag_offset = global_position - get_global_mouse_position()
			else:
				is_dragging = false
		
		# Try mouse wheel detection in _gui_input as well
		elif mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP and mouse_event.pressed:
			print("GUI Input: Mouse wheel up detected")
			zoom_in_at_mouse()
			accept_event()  # Mark event as handled
		elif mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN and mouse_event.pressed:
			print("GUI Input: Mouse wheel down detected")
			zoom_out_at_mouse()
			accept_event()  # Mark event as handled
	
	elif event is InputEventMouseMotion and is_dragging:
		# Update position while dragging
		global_position = get_global_mouse_position() + drag_offset

func zoom_in() -> void:
	print("Zooming in")
	var new_scale = scale.x * zoom_step
	if new_scale <= max_zoom:
		scale = Vector2(new_scale, new_scale)

func zoom_out() -> void:
	print("Zooming out")
	var new_scale = scale.x / zoom_step
	if new_scale >= min_zoom:
		scale = Vector2(new_scale, new_scale)

# Zoom functions that center on mouse position
func zoom_in_at_mouse() -> void:
	var mouse_pos = get_global_mouse_position()
	var old_scale = scale.x
	var new_scale = old_scale * zoom_step
	
	if new_scale <= max_zoom:
		# Calculate position adjustment to zoom towards mouse
		var rect_center = global_position + size * scale * 0.5
		var mouse_offset = mouse_pos - rect_center
		
		scale = Vector2(new_scale, new_scale)
		
		# Adjust position so zoom centers on mouse
		var scale_change = new_scale / old_scale
		var position_adjustment = mouse_offset * (1.0 - 1.0 / scale_change)
		global_position -= position_adjustment

func zoom_out_at_mouse() -> void:
	var mouse_pos = get_global_mouse_position()
	var old_scale = scale.x
	var new_scale = old_scale / zoom_step
	
	if new_scale >= min_zoom:
		# Calculate position adjustment to zoom towards mouse
		var rect_center = global_position + size * scale * 0.5
		var mouse_offset = mouse_pos - rect_center
		
		scale = Vector2(new_scale, new_scale)
		
		# Adjust position so zoom centers on mouse
		var scale_change = new_scale / old_scale
		var position_adjustment = mouse_offset * (1.0 - 1.0 / scale_change)
		global_position -= position_adjustment
