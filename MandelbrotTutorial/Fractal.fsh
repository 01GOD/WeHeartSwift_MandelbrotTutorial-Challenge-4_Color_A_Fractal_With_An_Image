void main() {
#define iterations 128

    vec2 position = v_tex_coord; // gets the location of the current pixel in the intervals [0..1] [0..1]

    position.y = 1.0 - position.y;

    vec2 z = offset + position / zoom;

    z *= 2.0;
    z -= vec2(1.0,1.0);

//    float aspectRatio = u_sprite_size.x / u_sprite_size.y;
//    z.x *= aspectRatio;

//    vec2 c = vec2(-0.76, 0.15);

    vec4 color = vec4(0.0); // initialize color to black

    float it = 0.0; // Keep track of what iteration we reached
    for (int i = 0;i < iterations; ++i) {
        // zn = zn-1 ^ 2 + c

        // (x + yi) ^ 2 = x ^ 2 - y ^ 2 + 2xyi
        z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y);
        z += c;

        if (z.x > 0.99 || z.y > 0.99 || z.x < 0.01 || z.y < 0.01) {
            color = vec4(0.0);
        } else {
            color = texture2D(image,z);
        }

        if (dot(z,z) > 4.0 || color.w > 0.1) { // dot(z,z) == length(z) ^ 2 only faster to compute
            break;
        }

        it += 1.0;
    }

    if (color.w < 0.1) {

        float s = it / 80.0;
        color = vec4(s,s,s,1.0);
    }

    gl_FragColor = color;
}
