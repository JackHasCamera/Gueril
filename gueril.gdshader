shader_type canvas_item;

// uniform for number of layers to separate
uniform int layers = 1;
uniform int smoothness = 0;

void fragment() {
	vec4 blurred_color = vec4(0.0);
	float total_weight = 0.0;
	
	// Apply Gaussian blur if smoothness > 0
	if (smoothness > 0) {
		int radius = smoothness;
		for (int x = -radius; x <= radius; x++) {
			for (int y = -radius; y <= radius; y++) {
				vec2 offset = vec2(float(x), float(y)) * TEXTURE_PIXEL_SIZE;
				float weight = exp(-float(x*x + y*y) / (2.0 * float(radius * radius)));
				blurred_color += texture(TEXTURE, UV + offset) * weight;
				total_weight += weight;
			}
		}
		blurred_color /= total_weight;
	} else {
		// No blur, use original texture
		blurred_color = texture(TEXTURE, UV);
	}
	
	// Make texture greyscale and quantized based on layer count
	float grey = dot(blurred_color.rgb, vec3(0.299, 0.587, 0.114));
	
	// Prevent division by zero when layers = 1
	float divisor = max(float(layers - 1), 1.0);
	float quantized = floor(grey * float(layers)) / divisor;
	
	COLOR = vec4(vec3(quantized), blurred_color.a);
}