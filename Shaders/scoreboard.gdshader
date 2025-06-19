shader_type canvas_item;

uniform float rows = 2000;

void fragment() {
	// Called for every pixel the material is visible on.
	bool isEven = mod(floor(rows * UV.y), 2) == 0.0;

	if(isEven){
		COLOR = vec4(0.25, 0.25, 0.25, 1);
	} else {
		COLOR = vec4(0.3, 0.3, 0.3, 1);
	}



}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
