shader_type canvas_item;

// uniform for number of layers to separate

uniform int layers = 1;
// smoothness slider: integer expected from the editor. It now controls
// the strength of the blur. We expose a max so the slider range can be
// easily matched in the Inspector. Increase `smoothness_max` if you
// want a larger radius/more dramatic blur.
uniform int smoothness = 0;
uniform int smoothness_max = 10;

void fragment() {
	// Keep the blur code available (for other creative uses), but
	// compute the posterize bands from the ORIGINAL texture sample
	// so any blur/smoothness does NOT cause feathered edges.
	vec4 blurred_color = vec4(0.0);
	float total_weight = 0.0;
	if (smoothness > 0) {
		// Cap radius to the configured max to avoid excessive loops.
		int radius = min(smoothness, smoothness_max);
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
		blurred_color = texture(TEXTURE, UV);
	}

	// Sample the original texture (non-blurred) for posterization so
	// the quantization produces hard, solid bands with no feathering by default.
	vec4 base_color = texture(TEXTURE, UV);
	float grey_base = dot(base_color.rgb, vec3(0.299, 0.587, 0.114));

	// Also compute posterized value from the blurred sample so we can
	// optionally blend between hard and soft posterize depending on the
	// smoothness slider. This keeps the slider usable while preserving
	// hard bands at smoothness == 0.
	float grey_blur = dot(blurred_color.rgb, vec3(0.299, 0.587, 0.114));

	// Map smoothness to a 0..1 mix relative to the configured max so the
	// slider controls both radius (above) and the blend strength.
	float mix_amount = clamp(float(smoothness) / max(float(smoothness_max), 1.0), 0.0, 1.0);

	// Blend the greys first, then quantize. This guarantees the final
	// output has exactly `layers` discrete bands regardless of smoothness.
	float final_q;
	if (layers <= 1) {
		float grey_blend = mix(grey_base, grey_blur, mix_amount);
		final_q = grey_blend;
	} else {
		float f_layers = float(layers);
		float denom = max(f_layers - 1.0, 1.0);
		float grey_blend = mix(grey_base, grey_blur, mix_amount);
		float band = floor(grey_blend * f_layers);
		final_q = band / denom;
	}

	COLOR = vec4(vec3(final_q), base_color.a);
}