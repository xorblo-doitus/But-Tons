shader_type spatial;

uniform vec3 base_color : source_color = vec3(0, 0, 0);
uniform vec3 on_color : source_color = vec3(1, 0.5, 0);
instance uniform float progress: hint_range(0.0, 1.0) = 0.25;


void fragment() {
	ROUGHNESS = 0.5;
	METALLIC = 0.5;
	if (UV.x <= progress) {
		ALBEDO = on_color;
		EMISSION = on_color;
	} else {
		ALBEDO = base_color;
	}
}
