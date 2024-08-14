const std = @import("std");
const expectEqual = std.testing.expectEqual;

test "capture syntax" {
    const items = [_]u32{ 1, 3, 5 };

    var sum: u32 = 0;
    for (items) |value| {
        sum += value;
    }

    try expectEqual(9, sum);
}

test "range syntax" {
    var sum: usize = 0;

    // Ranges in for loops are always exclusive,
    // meaning the final number is not included:
    for (0..5) |i| {
        sum += i;
    }

    try expectEqual(10, sum);
}

test "index value" {
    const items = [_]u32{ 1, 3, 5 };
    var sum: usize = 0;

    // Use an unbounded range as the second item
    // to capture the current index of iteration:
    for (items, 0..) |value, i| {
        _ = value;
        sum += i;
    }

    try expectEqual(3, sum);
}

test "multiple objects" {
    const items_a = [_]usize{ 0, 1, 2 };
    const items_b = [_]usize{ 3, 4, 5 };
    var sum: usize = 0;

    // All lengths must be equal at the start of the loop,
    // otherwise detectable illegal behavior occurs.
    for (items_a, items_b) |a, b| {
        sum += a + b;
    }

    try expectEqual(15, sum);
}

test "value by reference" {
    var items = [_]u32{ 1, 2, 3 };

    // Using a pointer capture:
    for (&items) |*value| {
        value.* += 1;
    }

    try expectEqual(2, items[0]);
    try expectEqual(3, items[1]);
    try expectEqual(4, items[2]);
}

test "for else" {
    const items = [_]u32{ 1, 7, 0, 4, 5 };

    for (items) |value| {
        if (value == 4) break;
    } else {
        // Since `items` does indeed contain 4,
        // the break statement above is reached
        // and this block is never evaluated.
        return error.NotFound;
    }

    // do more stuff...
}
