const std = @import("std");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

// If statements and expressions have three uses, corresponding to three types:
// - bool
// - ?T
// - anyerror!T

test "if expression" {
    // If expressions are used rather than ternary expressions:

    const a: u32 = 5;
    const b: u32 = 4;
    const result = if (a != b) 9001 else 0;
    try expectEqual(9001, result);
}

test "if boolean" {
    // If statements that test for true:

    const a: u32 = 3;
    const b: u32 = 4;
    if (a != b) {
        try expect(true);
    } else if (a == 7) {
        unreachable;
    } else {
        unreachable;
    }

    // The else is optional:
    if (a != b) {
        try expect(true);
    }
}

test "if optional" {
    // If statements that test for null:

    const a: ?u32 = 0;
    if (a) |value| {
        try expectEqual(0, value);
    } else {
        unreachable;
    }

    const b: ?u32 = null;
    if (b) |_| {
        unreachable;
    } else {
        try expect(true);
    }

    // The else is optional:
    if (a) |value| {
        try expectEqual(0, value);
    }

    // To test for just `null`, use the binary equality operator:
    if (b == null) {
        try expect(true);
    }

    // Access the value by reference using a pointer capture:
    var c: ?u32 = 3;
    if (c) |*value| {
        value.* = 7;
    }

    if (c) |value| {
        try expectEqual(7, value);
    } else {
        unreachable;
    }
}

test "if error union" {
    // If statements that test for errors:

    // An example of an error union containing a non-error value:
    const a: anyerror!u32 = 0;
    if (a) |value| {
        try expectEqual(0, value);
    } else |err| {
        _ = err;
        unreachable;
    }

    // An example of an error union containing an error value:
    const b: anyerror!u32 = error.BadValue;
    if (b) |value| {
        _ = value;
        unreachable;
    } else |err| {
        try expectEqual(error.BadValue, err);
    }

    // The else and |err| capture is strictly required.
    if (a) |value| {
        try expectEqual(0, value);
    } else |_| {}

    // To check only the error value, use an empty block expression.
    if (b) |_| {} else |err| {
        try expectEqual(error.BadValue, err);
    }

    // Access the value by reference using a pointer capture.
    var c: anyerror!u32 = 3;
    if (c) |*value| {
        value.* = 7;
    } else |_| {
        unreachable;
    }

    if (c) |value| {
        try expectEqual(7, value);
    } else |_| {
        unreachable;
    }
}

test "if error union with optional" {
    // If statements and expressions test for errors before unwrapping optionals.
    // The |optional_value| capture's type is ?u32.

    const a: anyerror!?u32 = 0;
    if (a) |optional_value| {
        try expectEqual(0, optional_value.?);
    } else |err| {
        _ = err;
        unreachable;
    }

    const b: anyerror!?u32 = null;
    if (b) |optional_value| {
        try expectEqual(null, optional_value);
    } else |_| {
        unreachable;
    }

    const c: anyerror!?u32 = error.BadValue;
    if (c) |optional_value| {
        _ = optional_value;
        unreachable;
    } else |err| {
        try expectEqual(error.BadValue, err);
    }

    // Access the value by reference by using a pointer capture each time:
    var d: anyerror!?u32 = 3;
    if (d) |*optional_value| {
        if (optional_value.*) |*value| {
            value.* = 7;
        }
    } else |_| {
        unreachable;
    }

    if (d) |optional_value| {
        try expectEqual(7, optional_value.?);
    } else |_| {
        unreachable;
    }
}
