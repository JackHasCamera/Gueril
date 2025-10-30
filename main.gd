extends Control

@export var preview_shader: ShaderMaterial

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Enable input processing for debugging
	set_process_input(true)
	
	# Connect the layer count slider to update shader
	var layer_slider = $"BoxContainer/Layer_Count" as HSlider
	if layer_slider and not layer_slider.value_changed.is_connected(_on_layer_count_value_changed):
		layer_slider.value_changed.connect(_on_layer_count_value_changed)

# Debug function to see if mouse wheel events reach the main control
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			print("MAIN CONTROL: Mouse wheel up detected")
		elif mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			print("MAIN CONTROL: Mouse wheel down detected")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_new_stencil_pressed() -> void:
	$FileDialog.popup_centered() # Or $FileDialog.visible = true

func _on_file_dialog_file_selected(path: String) -> void:
	print(path) # Replace with function body.
	# set selected image as texture of the Preview TextureRect
	var img = Image.new()
	var err = img.load(path)
	if err == OK:
		var tex = ImageTexture.create_from_image(img)
		$Preview.texture = tex
		$Preview.scale = Vector2(1, 1)  # Reset zoom
		
		# Adjust preview size to match image aspect ratio
		var image_size = img.get_size()
		var aspect_ratio = image_size.x / image_size.y
		
		# Set a base height and calculate width based on aspect ratio
		var base_height = 400.0  # You can adjust this base size
		var new_width = base_height * aspect_ratio
		
		$Preview.size = Vector2(new_width, base_height)
		$Preview.custom_minimum_size = Vector2(new_width, base_height)
	else:
		print("Failed to load image: ", err)

func _on_layer_count_value_changed(value: float) -> void:
	# Update the shader parameter when slider changes
	var shader_material = $Preview.material as ShaderMaterial
	if shader_material:
		shader_material.set_shader_parameter("layers", int(value))
		#print("Updated shader layers to: ", int(value))

func _on_smoothness_value_changed(value: float) -> void:
	# Update the shader parameter when slider changes
	var shader_material = $Preview.material as ShaderMaterial
	if shader_material:
		shader_material.set_shader_parameter("smoothness", value)
		#print("Smoothness slider changed to: ", value)
