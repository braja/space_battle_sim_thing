shader_type canvas_item;

uniform vec4 tint_color : source_color = vec4(0.5, 1.0, 0.5, 0.5);

void fragment() {
    vec4 texture_color = texture(TEXTURE, UV);
    COLOR = texture_color * tint_color;
}
