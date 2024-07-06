const std = @import("std");

test "if statement" {
    if (true == true) {
        std.debug.print(" All is well. 👍 ", .{});
    } else {
        @compileError("Something has gone horribly wrong.");
    }
}
