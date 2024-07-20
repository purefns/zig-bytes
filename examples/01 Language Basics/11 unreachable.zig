const std = @import("std");
const expectEqual = std.testing.expectEqual;

fn asciiToUpper(x: u8) u8 {
    return switch (x) {
        'a'...'z' => x + 'A' - 'a',
        'A'...'Z' => x,
        // Using `unreachable` here tells the compiler that this branch
        // is impossible, which the optimiser can take advantage of.
        else => unreachable,
    };
}

test "unreachable switch" {
    try expectEqual('R', asciiToUpper('r'));
    try expectEqual('C', asciiToUpper('C'));
}

test "unreachable" {
    const x: u8 = 5;
    // Since `unreachable` is of type `noreturn`, it can
    // coerce to `u8` no problem.
    const y: u8 = if (x == 4) 3 else unreachable;
    _ = y;
}
