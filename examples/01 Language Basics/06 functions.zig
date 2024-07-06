const std = @import("std");
const expectEqual = std.testing.expectEqual;

// DO NOT USE THIS IN PRODUCTION!!!1!
fn square(x: u8) u8 {
    return x * x;
}

test "function" {
    const y = square(2);
    try expectEqual(u8, @TypeOf(y));
    try expectEqual(4, y);
}

fn fibonacci(n: u16) u64 {
    if (n == 0 or n == 1) return n;
    return fibonacci(n - 1) + fibonacci(n - 2);
}

test "function recursion" {
    try expectEqual(832040, fibonacci(30));
}
