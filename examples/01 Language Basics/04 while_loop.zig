const std = @import("std");
const expect = std.testing.expect;

test "while" {
    var a: u16 = 2;
    while (a < 100) {
        a *= a;
    }
    try expect(a == 256);
}

test "while with continue expression" {
    var sum: u16 = 0;
    var i: u8 = 1;
    while (i <= 42) : (i += 1) {
        sum += i;
    }
    try expect(sum == 903);
}

test "while with continue keyword" {
    var sum: u16 = 0;
    var i: u8 = 1;
    while (i <= 42) : (i += 1) {
        if (i == 10) continue;
        sum += i;
    }
    try expect(sum == 893);
}

test "while with break keyword" {
    var sum: u16 = 0;
    var i: u8 = 1;
    while (i <= 42) : (i += 1) {
        if (i == 10) break;
        sum += i;
    }
    try expect(sum == 45);
}
