const std = @import("std");
const expectEqual = std.testing.expectEqual;

// There are no exceptions in Zig - errors are values! This is an error set, a commonly used pattern.
const FileOpenError = error{
    AccessDenied,
    OutOfMemory,
    FileNotFound,
};

const AllocationError = error{OutOfMemory};

test "coerce error from a subset to a superset" {
    // Since `AllocationError` is a subset of `FileOpenError`, it can coerce to the `FileOpenError` type.
    const err: FileOpenError = AllocationError.OutOfMemory;
    try expectEqual(FileOpenError.OutOfMemory, err);
}

test "error union" {
    // Error unions are Zig's way of encapsulating possible error states in fallible functions.
    const maybe_error: AllocationError!u16 = 10;
    // By using catch (similar to `unwrap*` in other languages), you can react to these error states.
    // In this example, we are returning a default value, but you can also use a value of type
    // `noreturn` (the type of `return`, `while(true)`, and others).
    const no_error = maybe_error catch 0;

    try expectEqual(u16, @TypeOf(no_error));
    try expectEqual(10, no_error);
}

// returning an error

fn fallibleFunction() error{NotSure}!void {
    return error.NotSure;
}

test "returning an error" {
    // Here, we use `catch` to capture a fallible function's error value (if present).
    // The `|err|` syntax is called "payload capturing", and is used in many other places.
    fallibleFunction() catch |err| {
        try expectEqual(error.NotSure, err);
        return;
    };
}

// try

fn failFn() error{NotSure}!u32 {
    try fallibleFunction();
    return 42;
}

test "try" {
    const v = failFn() catch |err| {
        try expectEqual(error.NotSure, err);
        return;
    };
    // This will never be reached because `fallibleFunction` always return an error.
    //
    // Another interesting thing to note is the signature of this testing function
    // that we've been using, `expectEqual`, also returns an error union due to the
    // usage of `try`:
    //
    //     fn expectEqual(...) !void {}
    //
    try expectEqual(1, v);
}

// errdefer

var dogs: u32 = 100;

fn failFnCounter() error{NotSure}!void {
    errdefer dogs += 1;
    try fallibleFunction();
}

test "errdefer" {
    failFnCounter() catch |err| {
        try expectEqual(error.NotSure, err);
        try expectEqual(101, dogs);
        return;
    };
}

// inferred error sets

fn createFile() !void {
    return error.StillNotSure;
}

test "inferred error set" {
    // Type coercion successfully takes place
    const x: error{StillNotSure}!void = createFile();

    // In order to ignore error unions, you must also unwrap it by any means (`try`, `catch`, etc.).
    _ = x catch {};
}

// merging error sets

const SomeErr = error{ NotDir, PathNotFound };
const OtherErr = error{ OutOfMemory, PathNotFound };

// Error sets can be merged using the `||` operator.
const BigErr = SomeErr || OtherErr;

test "merging error sets" {
    // As before, the subset `SomeErr` can also coerce to the superset `BigErr`.
    const err: BigErr = SomeErr.PathNotFound;

    try expectEqual(BigErr.PathNotFound, err);
}
