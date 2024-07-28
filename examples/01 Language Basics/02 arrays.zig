const std = @import("std");

// Initialization using an array literal:
const hello = [_]u8{ 'H', 'e', 'l', 'l', 'o' };

// Using result location:
const alt_hello: [5]u8 = .{ 'H', 'e', 'l', 'l', 'o' };

// Using a string literal (a single-item pointer to an array):
const same_hello = "Hello";

comptime {
    // All of them are all the same
    std.debug.assert(std.mem.eql(u8, &hello, &alt_hello));
    std.debug.assert(std.mem.eql(u8, &hello, same_hello));

    // Get the size of an array
    std.debug.assert(hello.len == 5);
}

test "iterate over an array" {
    var sum: usize = 0;
    for (hello) |byte| {
        sum += byte;
    }
    try std.testing.expectEqual('H' + 'e' + 'l' * 2 + 'o', sum);
}

// A modifiable array:
var items: [100]u8 = undefined;

test "modifiable array" {
    // assigning by index:
    for (0..items.len) |i| {
        items[i] = @intCast(i);
    }
    // using a many-item pointer
    for (&items, 0..) |*item, i| {
        item.* = @intCast(i);
    }

    try std.testing.expectEqual(10, items[10]);
    try std.testing.expectEqual(99, items[99]);
}

// Array concatenation works if the values are known at compile time:
const array_one = [_]u32{ 1, 2, 3, 4 };
const array_two = [_]u32{ 5, 6, 7, 8 };
const both = array_one ++ array_two;
comptime {
    std.debug.assert(std.mem.eql(u32, &both, &[_]u32{ 1, 2, 3, 4, 5, 6, 7, 8 }));
}

// Remember that string literals are also arrays:
const world = "world";
const hello_world = hello ++ " " ++ world;

// Use '**' to repeat elements:
const pattern = "zig" ** 3;
comptime {
    std.debug.assert(std.mem.eql(u8, pattern, "zigzigzig"));
}

// Initialize an array to zero:
const zeroes = [_]u8{0} ** 10;
comptime {
    std.debug.assert(zeroes.len == 10);
    std.debug.assert(zeroes[5] == 0);
}

const Point = struct {
    x: u32,
    y: u32,
};

// Initialize an array at compile-time:
var comptime_array = blk: {
    var initial_value: [10]Point = undefined;
    for (&initial_value, 0..) |*pt, i| {
        pt.* = Point{
            .x = @intCast(i),
            .y = @intCast(i * 2),
        };
    }
    break :blk initial_value;
};

test "comptime array initialization" {
    try std.testing.expectEqual(3, comptime_array[3].x);
    try std.testing.expectEqual(6, comptime_array[3].y);
}

fn makePoint(x: u32) Point {
    return .{
        .x = x,
        .y = x * 2,
    };
}

var another_array = [_]Point{makePoint(3)} ** 10;

test "array initialization with function calls" {
    try std.testing.expectEqual(3, another_array[4].x);
    try std.testing.expectEqual(6, another_array[4].y);
    try std.testing.expectEqual(10, another_array.len);
}
