shader_type canvas_item;

uniform float rows = 30.0; // Row pixelation control

uniform vec4 color1 : source_color = vec4(0.11, 0.11, 0.11, 1.0);
uniform vec4 color2 : source_color =  vec4(0.22, 0.22, 0.22, 1.0);

void fragment() {
    // Row coloring logic
    bool is_even_row = mod(floor(UV.y * rows), 2.0) == 0.0;
    vec4 row_color = is_even_row ? color1 : color2;

	COLOR = row_color;
}