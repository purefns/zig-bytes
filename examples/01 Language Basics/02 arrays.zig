const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    // using a comptime-known value for the size
    const a = [12]u8{ 72, 101, 108, 108, 111, 32, 119, 111, 114, 108, 100, 33 };
    // for array literals, '_' lets the compiler infer the size
    const b = [_]u8{ 'B', 'y', 'e', '!' };

    // now we are printing to stdout instead of stderr
    try stdout.print("{s} {s}\n", .{ a, b });

    // 'len' holds the arrays' length
    try stdout.print("The length of a is {d}.\n", .{a.len});
}
