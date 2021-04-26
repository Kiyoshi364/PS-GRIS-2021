const std = @import("std");

fn dot(u: [2]i128, v: [2]i128) i128 {
    return u[0] * v[0] + u[1] * v[1];
}

fn len2(u: [2]i128) i128 {
    return dot(u, u);
}

fn gauss(a: [2]i128, b: [2]i128) [2][2]i128 {
    var v1: [2]i128 = a;
    var v2: [2]i128 = b;

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

    return .{ v1, v2 };
}

pub fn main() anyerror!void {
    var v1: [2]i128 = .{ 846835985, 9834798552 };
    var v2: [2]i128 = .{ 87502093, 123094980 };

    const ret = gauss(v1, v2);

    const r = dot(ret[0], ret[1]);

    std.debug.print("{}\n", .{r});
}
