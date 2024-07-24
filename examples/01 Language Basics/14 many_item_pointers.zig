const std = @import("std");
const expectEqual = std.testing.expectEqual;

test "many-item pointers" {
    const array = [_]i32{ 1, 2, 3, 4 };
    var ptr: [*]const i32 = &array;

    try expectEqual(1, ptr[0]);
    ptr += 1;
    try expectEqual(2, ptr[0]);

    // Slicing a many-item pointer without an end is equivalent to
    // pointer arithmetic: `ptr[start..] = ptr + start`
    try expectEqual(ptr + 1, ptr[1..]);
}
