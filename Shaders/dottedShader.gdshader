shader_type canvas_item;

uniform float rows = 2000.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    float y = floor(UV.y * rows);
    bool is_even = mod(y, 2.0) == 0.0;

    float alpha = is_even ? 0.8 : 1.0;
    COLOR = vec4(tex.rgb, tex.a * alpha);
}
