const std = @import("std");

pub fn main() !void {
    // `const` indicates that a variable is immutable
    const name = "Zig Dog";

    // `var` indicates that a variable is mutable
    var count: u32 = 0;

    // debug print to stderr, don't worry about the specifics right now
    std.debug.print("const name = {s}\n\n", .{name});
    std.debug.print("var count = {d}\n", .{count});

    // changing the mutable variable
    count += @as(u32, 1); // @as() performs explicit type coercion
    std.debug.print("var count = {d}\n\n", .{count});

    // undefined coerces to any type
    const undefined_const: i32 = undefined;
    // you will see some strange behavior when this prints
    std.debug.print("const undefined_const = {d}\n", .{undefined_const});

    // and `var` variables
    var undefined_var: i32 = undefined;
    undefined_var = -1;
    std.debug.print("var undefined_var = {d}\n", .{undefined_var});
}
