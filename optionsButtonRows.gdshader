shader_type canvas_item;

uniform sampler2D mask_texture;
uniform float rows = 200.0; // Row pixelation control

uniform vec4 color1 : source_color = vec4(0.9176, 0.5804, 0.2039, 1.0);
uniform vec4 color2 : source_color =  vec4(0.882, 0.616, 0.224, 1.0);

void fragment() {
    // Row coloring logic
    bool is_even_row = mod(floor(UV.y * rows), 2.0) == 0.0;
    vec4 row_color = is_even_row ? color1 : color2;

    vec4 mask = texture(mask_texture, UV);
	float luminance = dot(mask.rgb, vec3(0.299, 0.587, 0.114)); // standard grayscale conversion

	if (luminance > 0.5) {
    	discard;
	}

    // Show final masked + striped color
    COLOR = row_color;
}