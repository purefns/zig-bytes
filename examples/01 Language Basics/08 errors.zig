const std = @import("std");
const expectEqual = std.testing.expectEqual;

// An error set is very similar to an enum:
const FileOpenError = error{
    AccessDenied,
    OutOfMemory,
    FileNotFound,
};

// They can also have just one item:
const AllocationError = error{OutOfMemory};

test "coercing error sets" {
    // Since `AllocationError` is a subset of `FileOpenError`, it
    // can coerce to the `FileOpenError` type.
    const err: FileOpenError = AllocationError.OutOfMemory;
    try expectEqual(FileOpenError.OutOfMemory, err);

    // Coercing from a superset to a subset is not allowed, however.
    // If the comments below are removed, this will fail to compile.
    //
    // const err2: AllocationError = FileOpenError.OutOfMemory;
    // _ = err2;
}

const SystemError = FileOpenError || AllocationError;

test "merging error sets" {
    // As before, the subset `AllocationError` can also coerce
    // to the superset of `SystemError`.
    const err: SystemError = AllocationError.OutOfMemory;
    try expectEqual(SystemError.OutOfMemory, err);
}

test "error unions" {
    // An error union is like a burrito, where you have to unwrap it
    // to get to the stuff inside; it can either be good (some data),
    // or bad (an error), and it's up to you to deal with it:
    const burrito: AllocationError!u16 = 10;

    // In Zig, `catch` is how you unwrap that burrito. Here we are
    // returning a default value, but you can also use a value of
    // type `noreturn` (the type of `return`, `while (true)`, etc.)
    const unburrito = burrito catch 0;

    // Our burrito is nothing but good inside:
    try expectEqual(10, unburrito);
}

// Omit the error set in a function return type to let it be inferred:
fn createFile() !void {
    return error.OutOfMemory;
}

test "inferred error set" {
    // Type coercion successfully takes place
    const x: AllocationError!void = createFile();

    // In order to ignore error unions, it must also be unwrapped
    // using `try`, `catch`, or `if`
    _ = x catch {};
}

test "try" {
    const burrito: error{NotGood}!u8 = 42;

    // Using `try` is like assuming that your burrito is fine and
    // eating the whole thing, no matter the consequences:
    const unburrito = try burrito;

    // If that had been an error instead, the program would panic and
    // this code would never be reached:
    try expectEqual(42, unburrito);
}

var fail_count: u8 = 0;

fn fail() error{Failed}!void {
    // If an error is returned past this point, the statement after
    // the `errdefer` keyword will be evaluated before execution
    // returns to the caller of this function.
    errdefer fail_count += 1;

    // Go figure, it didn't work. Now, the `errdefer` above will be
    // evaluated, and then the error will finally be returned.
    return error.Failed;
}

test "errdefer" {
    fail() catch {
        // Since the `errdefer` statement above has been evaulated
        // by this point,
        try expectEqual(1, fail_count);
        return;
    };
}
