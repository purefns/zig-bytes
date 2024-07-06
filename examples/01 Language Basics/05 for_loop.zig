const std = @import("std");
const print = std.debug.print;

pub fn main() void {
    // character literals are equivalent to integer literals
    const binary_str = [_]u8{ 90, 'i', 103, 32 };
    const octal_str = [_]u8{ 73, 's', ' ' };
    const hex_str = [_]u8{ 71, 'r', 101, 'a', 116, 33 };

    // iterate over an array with an index
    for (binary_str, 0..) |character, i| {
        print("'{c}' in binary is:\t0b{b:0>8}\n", .{ character, binary_str[i] });
    }

    // just iterate over the array
    for (octal_str) |character| {
        print("'{c}' in octal is:\t0o{o:0>8}\n", .{ character, character });
    }

    // you can also ignore unused captures with '_'
    for (hex_str, 0..) |_, i| {
        print("'{c}' in hexidecimal is:\t0x{x:0>8}\n", .{ hex_str[i], hex_str[i] });
    }

    // interesting but probably useless
    for ("") |_| unreachable;
}
