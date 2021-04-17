const std = @import("std");
const math = std.math;

pub fn Vector(comptime dim: comptime_int) type {
    return struct {
        data: [dim]f64,

        const Self = @This();

        const empty: Self = Self{ .data = .{0} ** dim };

        pub fn init(data: [dim]f64) Self {
            return Self{ .data = data };
        }

        pub fn get0(self: Self, index: usize) f64 {
            return if (index < dim) self.data[index] else 0;
        }

        pub fn getErr(self: Self, index: usize) !f64 {
            return if (index < dim) self.data[index] else error.InvalidIndex;
        }

        pub fn add(self: Self, other: Self) Self {
            var new: Self = empty;
            for (new.data) |*val, i| {
                val.* = self.data[i] + other.data[i];
            }
            return new;
        }

        pub fn sub(self: Self, other: Self) Self {
            var new: Self = empty;
            for (new.data) |*val, i| {
                val.* = self.data[i] - other.data[i];
            }
            return new;
        }

        pub fn mul(self: Self, scalar: f64) Self {
            var new: Self = empty;
            for (new.data) |*val, i| {
                val.* = self.data[i] * scalar;
            }
            return new;
        }

        pub fn dot(self: Self, other: Self) f64 {
            var acc: f64 = 0;
            for (self.data) |val, i| {
                acc += val * other.data[i];
            }
            return acc;
        }

        pub fn squareLength(self: Self) f64 {
            return self.dot(self);
        }

        pub fn length(self: Self) f64 {
            return math.sqrt(self.squareLength());
        }

        pub fn projTo(self: Self, ref: Self) Self {
            var scalar: f64 = self.dot(ref) / ref.squareLength();
            return ref.mul(scalar);
        }

        pub fn projFrom(ref: Self, other: Self) Self {
            var scalar: f64 = other.dot(ref) / ref.squareLength();
            return ref.mul(scalar);
        }
    };
}

pub fn gramSchmidtNoNorm(comptime dim: comptime_int, basis: [dim]Vector(dim)) [dim]Vector(dim) {
    const V = Vector(dim);

    var newBasis: [dim]V = [1]V{V.empty} ** dim;
    for (newBasis) |*u, i| {
        u.* = basis[i];

        var preJ: usize = i;
        while (preJ > 0) : (preJ -= 1) {
            const j = preJ - 1;

            const w = basis[i].projTo(newBasis[j]);
            u.* = u.*.sub(w);
        }
    }

    return newBasis;
}

// Testing
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const expectEqualSlices = std.testing.expectEqualSlices;

const Vec2 = Vector(2);

fn expectEqualVec(comptime dim: comptime_int, v1: Vector(dim), v2: Vector(dim)) void {
    expectEqualSlices(f64, &v1.data, &v2.data);
}

test "2d init" {
    const a = Vec2.init(.{ 0, 1 });

    expectEqual(a.data, .{ 0, 1 });
}

test "2d get0" {
    const a = Vec2.init(.{ 1, 2 });

    expectEqual(a.get0(0), 1);
    expectEqual(a.get0(1), 2);
    expectEqual(a.get0(2), 0);
    expectEqual(a.get0(8763), 0);
}

test "2d getErr" {
    const a = Vec2.init(.{ 1, 2 });

    expectEqual(a.getErr(0), 1);
    expectEqual(a.getErr(1), 2);
    expectEqual(a.getErr(2), error.InvalidIndex);
    expectEqual(a.getErr(8763), error.InvalidIndex);
}

test "2d add" {
    const a = Vec2.init(.{ 1, 2 });
    const b = Vec2.init(.{ 2, 3 });

    expectEqualVec(2, a.add(b), Vec2.init(.{ 3, 5 }));
}

test "2d multply" {
    const a = Vec2.init(.{ 1, 2 });

    expectEqualVec(2, a.mul(4), Vec2.init(.{ 4, 8 }));
}

test "2d dot" {
    const a = Vec2.init(.{ 1, 2 });
    const b = Vec2.init(.{ 2, 3 });

    expectEqual(a.dot(b), 8);
}

test "2d squareLength" {
    const a = Vec2.init(.{ 4, 3 });

    expectEqual(a.squareLength(), 25);
}

test "2d length" {
    const a = Vec2.init(.{ 4, 3 });

    expectEqual(a.length(), 5);
}

test "2d projTo" {
    // TODO
    const a = Vec2.init(.{ 1, 2 });
    const b = Vec2.init(.{ 1, 2 });

    expectEqualVec(2, a.projTo(b), Vec2.init(.{ 1, 2 }));
}

test "2d projFrom" {
    // TODO
    const a = Vec2.init(.{ 1, 2 });
    const b = Vec2.init(.{ 1, 2 });

    expectEqualVec(2, a.projFrom(b), Vec2.init(.{ 1, 2 }));
}

test "2d gramSchmidtNoNorm" {
    // TODO
    const Vec4 = Vector(4);
    const v1 = Vec4.init(.{ 4, 1, 3, -1 });
    const v2 = Vec4.init(.{ 2, 1, -3, 4 });
    const v3 = Vec4.init(.{ 1, 0, -2, 7 });
    const v4 = Vec4.init(.{ 6, 2, 9, -5 });

    // const basis: []
}
