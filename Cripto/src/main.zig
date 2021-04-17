const std = @import("std");

const vector = @import("vector.zig");
const Vec3 = vector.Vector(3);

fn dot(u: [2]i128, v: [2]i128) i128 {
    return u[0] * v[0] + u[1] * v[1];
}

fn len2(u: [2]i128) i128 {
    return dot(u, u);
}

pub fn main() anyerror!void {
    var v1: [2]i128 = .{ 846835985, 9834798552 };
    var v2: [2]i128 = .{ 87502093, 123094980 };

    while (true) {
        if (len2(v2) < len2(v1)) {
            const tmp = v1;
            v1 = v2;
            v2 = tmp;
        }

        const m = @divFloor(dot(v1, v2), len2(v1));

        if (m == 0) break;

        v2 = .{ v2[0] - m * v1[0], v2[1] - m * v1[1] };
    }

    const r = dot(v1, v2);

    std.debug.print("{}\n", .{r});
}
