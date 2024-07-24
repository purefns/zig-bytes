const std = @import("std");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const expectEqualSlices = std.testing.expectEqualSlices;

test "slices" {
    var array = [_]u32{ 1, 2, 3, 4 };
    var known_at_runtime_zero: usize = 0;
    _ = &known_at_runtime_zero;
    const slice = array[known_at_runtime_zero..array.len];

    // a one-line version using result location
    const alt_slice: []const u32 = &.{ 1, 2, 3, 4 };

    try expectEqualSlices(u32, slice, alt_slice);

    try expectEqual([]u32, @TypeOf(slice));
    try expectEqual(&array[0], &slice[0]);
    try expectEqual(array.len, slice.len);

    // If you slice with comptime-known start and end positions, the result is a
    // pointer to an array, rather than a slice.
    const array_ptr = array[0..array.len];
    try expectEqual(*[array.len]u32, @TypeOf(array_ptr));

    // You can perform a slice-by-length by slicing twice. This allows the compiler
    // to perform some optimisations like recognzing a comptime-known length when
    // the start position is only known at runtime.
    var runtime_start: usize = 1;
    _ = &runtime_start;
    const length = 2;
    const array_ptr_len = array[runtime_start..][0..length];
    try expectEqual(*[length]u32, @TypeOf(array_ptr_len));

    // Using the address-of operator on a slice gives a single-item pointer.
    try expectEqual(*u32, @TypeOf(&slice[0]));
    // Using the `ptr` field gives a many-item pointer.
    try expectEqual([*]u32, @TypeOf(slice.ptr));
    try expectEqual(@intFromPtr(&slice[0]), @intFromPtr(slice.ptr));

    // Slices have array bounds checking. If you try to access something out
    // of bounds, you'll get a safety check failure:
    //
    // slice[10] += 1;

    // Note that `slice.ptr` does not invoke safety checking, while `&slice[0]`
    // asserts that the slice has len > 0.
}

test "strings, a.k.a slices" {
    // Zig doesn't have strings. String literals are really just `*const [n:0]u8`,
    // and parameters that are "strings" are expected to be UTF-8 encoded slices of `u8`.
    // Here, we coerce string literals (pointers) to slices.
    const hello: []const u8 = "hello";
    const world: []const u8 = "世界";

    var buf: [100]u8 = undefined;

    // You can use slice syntax with at least one runtime-known index on an array
    // to convert it to a slice.
    var start: usize = 0;
    _ = &start;
    const buf_slice = buf[start..];

    // An example of string concatenation:
    const hello_world = try std.fmt.bufPrint(buf_slice, "{s} {s}", .{ hello, world });

    // You can generally use UTF-8 and not worry about whether something is a string.
    // If you don't need to deal with individual characters, don't decode!
    try expect(std.mem.eql(u8, hello_world, "hello 世界"));
}
