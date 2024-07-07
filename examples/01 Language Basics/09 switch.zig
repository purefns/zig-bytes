const std = @import("std");
const expectEqual = std.testing.expectEqual;

test "switch statement" {
    var x: i8 = 100;
    switch (x) {
        -1...1 => {
            x = -x;
        },
        10, 100 => {
            // Special considerations must be made
            // when dividing signed integers
            x = @divExact(x, 10);
        },
        else => {},
    }
    try expectEqual(10, x);
}

// The same thing, but as an expression:

test "switch expression" {
    var x: i8 = 100;
    x = switch (x) {
        -1...1 => -x,
        10, 100 => @divExact(x, 10),
        else => x,
    };
    try expectEqual(10, x);
}
