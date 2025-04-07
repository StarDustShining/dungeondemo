shader_type canvas_item;

uniform vec2 center; // UV 中心 (0~1)
uniform float radius; // 可视圆半径
uniform float softness : hint_range(0.0, 0.5) = 0.1;

void fragment() {
    vec2 uv = UV;
    float dist = distance(uv, center);

    // alpha 越大，越黑；我们想让中间透明、外圈变黑
    float alpha = smoothstep(radius, radius - softness, dist);
    alpha = 1.0 - alpha; // ← 修正反方向

    COLOR = vec4(0.0, 0.0, 0.0, alpha);
}
