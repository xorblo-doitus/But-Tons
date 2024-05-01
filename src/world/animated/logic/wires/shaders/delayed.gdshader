shader_type spatial;

uniform vec3 base_color : source_color = vec3(0, 0, 0);
uniform vec3 on_color : source_color = vec3(0, 1, 1);
uniform sampler2D on_gradient;


void fragment() {
	ROUGHNESS = 0.5;
	METALLIC = 0.5;
	if (texture(on_gradient, UV).r > 0.5) {
		ALBEDO = on_color;
		EMISSION = on_color;
	} else {
		ALBEDO = base_color;
	}
}
