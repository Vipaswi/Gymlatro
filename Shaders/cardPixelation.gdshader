shader_type canvas_item;

uniform int amount = 100;

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 grid_uv = round(UV * float(amount)) / float(amount);

	vec4 text = texture(TEXTURE, grid_uv);

	COLOR = text;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
