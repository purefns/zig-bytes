const std = @import("std");

test "out of bounds, no safety" {
    @setRuntimeSafety(false);
    const a = [_]u8{ 1, 2, 3 };

    var index: u8 = 5;
    _ = &index;

    const b = a[index];
    _ = b;
}

test "out of bounds" {
    const a = [_]u8{ 1, 2, 3 };

    var index: u8 = 5;
    _ = &index;

    const b = a[index];
    _ = b;
}
