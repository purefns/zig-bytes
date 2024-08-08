const std = @import("std");
const expectEqual = std.testing.expectEqual;

test "while" {
    var a: u16 = 2;
    while (a < 8) {
        a *= 2;
    }
    try expectEqual(8, a);
}

test "while with break keyword" {
    var b: u8 = 1;
    while (true) {
        if (b == 16) break;
        b *= 2;
    }
    try expectEqual(16, b);
}

test "while with continue keyword" {
    var c: u8 = 1;
    while (true) {
        c *= 2;
        if (c <= 16) continue;
        break;
    }
    try expectEqual(32, c);
}

test "while with continue expression" {
    var d: u8 = 1;
    while (d <= 32) : (d *= 2) {}
    try expectEqual(64, d);
}

test "labelled while" {
    // Example of a nested break:
    outer: while (true) {
        while (true) {
            break :outer;
        }
    }

    // Example of a nested continue:
    var e: u8 = 1;
    outer: while (e <= 64) : (e *= 2) {
        while (true) {
            continue :outer;
        }
    }
    try expectEqual(128, e);
}

test "while with optionals" {
    var f: u8 = 0;
    items_left = 4;
    while (eventuallyNullSequence()) |value| {
        f += value;
    }
    try expectEqual(6, f);

    // null capture with an else block
    var g: u8 = 0;
    items_left = 4;
    while (eventuallyNullSequence()) |value| {
        g += value;
    } else {
        try expectEqual(6, g);
    }

    // null capture with a continue expression
    var h: u8 = 0;
    var count: u8 = 0;
    items_left = 4;
    while (eventuallyNullSequence()) |value| : (count += 1) {
        h += value;
    }
    try expectEqual(4, count);
}

var items_left: u8 = undefined;
fn eventuallyNullSequence() ?u8 {
    return if (items_left == 0) null else blk: {
        items_left -= 1;
        break :blk items_left;
    };
}

test "while with error unions" {
    var i: u8 = 0;
    items_left = 4;
    while (eventuallyErrorSequence()) |value| {
        i += value;
    } else |err| {
        try expectEqual(error.OutOfItems, err);
    }
}

fn eventuallyErrorSequence() !u8 {
    return if (items_left == 0) error.OutOfItems else blk: {
        items_left -= 1;
        break :blk items_left;
    };
}

test "inline while" {
    comptime var i: u8 = 0;
    var sum: usize = 0;
    inline while (i < 3) : (i += 1) {
        // Types can be used as first-class values now!
        const T = switch (i) {
            0 => u65535,
            1 => comptime_int,
            2 => anyopaque,
            else => unreachable,
        };
        sum += @typeName(T).len;
    }
    try expectEqual(27, sum);
}

// NOTE: It's recommended to only `inline` loops for one of two reasons:
//       - You need the loop to execute at comptime for the semantics to work.
//       - You have a benchmark to prove that doing so is measurably faster.
