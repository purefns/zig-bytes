const std = @import("std");
const expectEqual = std.testing.expectEqual;

test "defer" {
    var x: i16 = -2;
    {
        // this gets executed at the end of the current block
        defer x += 5;
        // therefore `x` should still be -2 here
        try expectEqual(-2, x);
    }
    try expectEqual(3, x);
}

test "multiple defer" {
    var y: f32 = 5;
    {
        // multiple defer statements are executed in reverse order
        defer y += 2;
        defer y /= 2;
    }
    try expectEqual(4.5, y);
}
