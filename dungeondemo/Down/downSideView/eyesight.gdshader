shader_type canvas_item;

void fragment() {
    vec4 o = texture(TEXTURE, UV);
    vec2 texture_size = 1.0 / TEXTURE_PIXEL_SIZE;
    vec2 pos = vec2(UV.x*texture_size.x, (1.0 - UV.y)*texture_size.y);

    // 计算最大圆形半径（取纹理宽高中的较小值的一半）
    float max_radius = min(texture_size.x, texture_size.y) * 0.45;

    if ((pow(pos.x - texture_size.x*0.5, 2.0) + pow(pos.y - texture_size.y*0.5, 2.0) <= pow(max_radius, 2.0))) {
        o.a = 0.1;
    } else {
        o.a = 0.0;
    }

    COLOR = o;
}
