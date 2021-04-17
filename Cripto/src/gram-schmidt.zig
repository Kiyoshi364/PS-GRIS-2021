const std = @import("std");

const vector = @import("vector.zig");
const Vec4 = vector.Vector(4);

pub fn main() anyerror!void {
    const v1 = Vec4.init(.{ 4, 1, 3, -1 });
    const v2 = Vec4.init(.{ 2, 1, -3, 4 });
    const v3 = Vec4.init(.{ 1, 0, -2, 7 });
    const v4 = Vec4.init(.{ 6, 2, 9, -5 });

    const basis = [_]Vec4{ v1, v2, v3, v4 };

    const r = vector.gramSchmidtNoNorm(4, basis);
    std.debug.print("[\n\t{},\n\t{},\n\t{},\n\t{}\n]\n", .{
        r[0].data, r[1].data, r[2].data, r[3].data,
    });
}
