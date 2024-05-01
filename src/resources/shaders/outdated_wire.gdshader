shader_type spatial;

uniform vec3 base_color : source_color = vec3(0, 0, 0);
uniform vec3 on_color : source_color = vec3(0, 1, 1);
uniform vec3 radiance_color : source_color = vec3(1, 1, 1);
uniform float radiance = 5.0;
instance uniform float on_start: hint_range(0.0, 1.0) = 0.25;
instance uniform float on_end: hint_range(0.0, 1.0) = 0.75;


void vertex() {
}

void fragment() {
	ROUGHNESS = 0.5;
	METALLIC = 0.5;
	if (on_start <= UV.x && UV.x <= on_end) {
		ALBEDO = on_color;
		//ALBEDO = mix(base_color, on_color, 20.0*min(abs(UV.x - on_start), abs(UV.x - on_end)));
		//RADIANCE = vec4(radiance_color.r, radiance_color.g, radiance_color.b, radiance);
		EMISSION = on_color;
	} else {
		ALBEDO = base_color;
	}
	//ALBEDO.r = UV.x;
	//COLOR = base_color;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
	//DIFFUSE_LIGHT += clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION * LIGHT_COLOR;
	//DIFFUSE_LIGHT += dot(NORMAL, LIGHT) * ATTENUATION * ALBEDO;
//}
