const std = @import("std");
const builtin = @import("builtin");

const math = std.math;

const print = std.debug.print;
const allocPrint = std.fmt.allocPrint;

const MEM_KB = math.pow(usize, 2, 10);
const MEM_MB: usize = MEM_KB * MEM_KB;
const MAX_MEM_BYTES: usize = 1 * MEM_MB;

const stderr = std.io.getStdErr();
const stdout = std.io.getStdOut();

const log = std.log.scoped(.main);
pub fn main() !void {
    var output: [MAX_MEM_BYTES]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&output);
    const allocator = fba.allocator();

    var path_buf: [1024]u8 = undefined;
    const exe_path = try std.fs.selfExePath(&path_buf);

    if (builtin.os.tag == .linux) {
        const argv = &[_][]const u8{
            "bash",
            "-c",
            try allocPrint(allocator, "set -x; readelf -h '{s}'", .{exe_path}),
        };

        const child_log = std.log.scoped(.child);
        const result = std.process.Child.run(.{
            .allocator = allocator,
            .argv = argv,
            .max_output_bytes = output.len,
        }) catch |err| {
            var dump_trace = false;
            switch (err) {
                error.FileNotFound => {
                    dump_trace = true;
                    child_log.err("Failed to find executable: {s}", .{argv[0]});
                },
                else => {},
            }
            return if (dump_trace) {
                if (@errorReturnTrace()) |et| std.debug.dumpStackTrace(et.*);
            };
        };

        const exit_code = result.term.Exited;
        if (exit_code != 0) child_log.err("Process exited with code {d}:\n", .{exit_code});

        try stderr.writeAll(result.stderr);
        try stdout.writeAll(result.stdout);
    } else if (builtin.os.tag == .windows or builtin.os.tag == .uefi) {
        log.err("Not yet implemented for Windows.", .{});
    }
}
