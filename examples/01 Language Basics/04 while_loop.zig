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
