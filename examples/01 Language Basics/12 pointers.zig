const std = @import("std");
const expectEqual = std.testing.expectEqual;

fn addOne(num: *u8) void {
    num.* += 1;
}

test "pointers" {
    var x: u8 = 0;
    addOne(&x);
    try expectEqual(1, x);
}

test "const pointers" {
    var x: u8 = 1;

    const y = &x;
    y.* += 1;
}

// Trying to set a `*T` to 0 is illegal behavior (that will be punished).
test "arrest this pointer" {
    var x: u16 = 0;
    _ = &x;

    var y: *u8 = @ptrFromInt(x);
    _ = &y;
}
