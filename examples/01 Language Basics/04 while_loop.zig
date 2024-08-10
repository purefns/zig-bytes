const std = @import("std");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

test "while" {
    var a: u16 = 1;
    while (a < 4) {
        a *= 2;
    }
    try expectEqual(4, a);
}

test "while with break keyword" {
    var b: u8 = 1;
    while (true) {
        if (b == 8) break;
        b *= 2;
    }
    try expectEqual(8, b);
}

test "while with continue keyword" {
    var c: u8 = 1;
    while (true) {
        c *= 2;
        if (c < 16) continue;
        break;
    }
    try expectEqual(16, c);
}

test "while with continue expression" {
    var d: u8 = 1;
    while (d < 32) : (d *= 2) {}
    try expectEqual(32, d);
}

test "while with crazier continue expression" {
    var e: u8 = 1;
    var f: u8 = 1;
    while (e + f < 64) : ({
        e *= 2;
        f *= 2;
    }) {}
    try expectEqual(64, e + f);
}

test "while expression" {
    try expect(rangeHasNumber(0, 10, 5));
    try expect(!rangeHasNumber(0, 10, 15));
}

fn rangeHasNumber(begin: usize, end: usize, number: usize) bool {
    var cur = begin;
    return while (cur < end) : (cur += 1) {
        if (cur == number) {
            break true;
        }
    } else false;
}

test "labelled while" {
    // Example of a nested break:
    outer: while (true) {
        while (true) {
            break :outer;
        }
    }

    // Example of a nested continue:
    var g: u8 = 1;
    outer: while (g < 128) : (g *= 2) {
        while (true) {
            continue :outer;
        }
    }
    try expectEqual(128, g);
}

test "while with optionals" {
    var h: u8 = 0;
    items_left = 4;
    while (eventuallyNullSequence()) |value| {
        h += value;
    }
    try expectEqual(6, h);

    // null capture with an else block
    var i: u8 = 0;
    items_left = 4;
    while (eventuallyNullSequence()) |value| {
        i += value;
    } else {
        try expectEqual(6, i);
    }

    // null capture with a continue expression
    var j: u8 = 0;
    items_left = 4;
    while (eventuallyNullSequence()) |value| : (j += 1) {
        j += value;
    }
    try expectEqual(10, j);
}

var items_left: u8 = undefined;
fn eventuallyNullSequence() ?u8 {
    return if (items_left == 0) null else blk: {
        items_left -= 1;
        break :blk items_left;
    };
}

test "while with error unions" {
    var k: u8 = 0;
    items_left = 4;
    while (eventuallyErrorSequence()) |value| {
        k += value;
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

// NOTE: It's recommended to only `inline` loops for one of two reasons:
//       - You need the loop to execute at comptime for the semantics to work.
//       - You have a benchmark to prove that doing so is measurably faster.

test "inline while" {
    comptime var l: u8 = 0;
    var sum: usize = 0;
    inline while (l < 3) : (l += 1) {
        // Types can be used as first-class values now!
        const T = switch (l) {
            0 => u65535,
            1 => comptime_int,
            2 => anyopaque,
            else => unreachable,
        };
        sum += @typeName(T).len;
    }
    try expectEqual(27, sum);
}
