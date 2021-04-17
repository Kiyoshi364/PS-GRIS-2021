const std = @import("std");

const vector = @import("vector.zig");
const Vec3 = vector.Vector(3);

pub fn main() anyerror!void {
    const v1 = Vec3.init(.{ 6, 2, -3 });
    const v2 = Vec3.init(.{ 5, 1, 4 });
    const v3 = Vec3.init(.{ 2, 7, 1 });

    const l1 = v1.get0(0) * v2.get0(1) * v3.get0(2);
    const l2 = v1.get0(1) * v2.get0(2) * v3.get0(0);
    const l3 = v1.get0(2) * v2.get0(0) * v3.get0(1);
    const l4 = v1.get0(0) * v2.get0(2) * v3.get0(1);
    const l5 = v1.get0(1) * v2.get0(0) * v3.get0(2);
    const l6 = v1.get0(2) * v2.get0(1) * v3.get0(0);

    const det = l1 + l2 + l3 - l4 - l5 - l6;

    std.debug.print("{}\n", .{det});
}
