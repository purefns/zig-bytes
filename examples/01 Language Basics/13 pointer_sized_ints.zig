const std = @import("std");
const expectEqual = std.testing.expectEqual;

test "usize and isize" {
    try expectEqual(@sizeOf(usize), @sizeOf(*u8));
    try expectEqual(@sizeOf(isize), @sizeOf(*u8));

    // This will print '4' on 32-bit machines, and '8' on 64-bit machines.
    std.debug.print(" OS pointer size: {d} bits ...", .{@sizeOf(*u8)});
}
