const std = @import("std");
const builtin = @import("builtin");

const heap = std.heap;
const meta = std.meta;

const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;
const Build = std.Build;
const LazyPath = std.Build.LazyPath;
const Step = std.Build.Step;
const Type = std.builtin.Type;
const OptimizeMode = std.builtin.OptimizeMode;
const Child = std.process.Child;

const print = std.debug.print;

comptime {
    // NOTE: keep this in sync with 'flake.nix'
    const required_zig = "0.13.0";
    const current_zig = builtin.zig_version;
    const min_zig = std.SemanticVersion.parse(required_zig) catch unreachable;
    if (current_zig.order(min_zig) == .lt) {
        const error_message =
            \\Sorry, it looks like your version of Zig is too old... :(
            \\
            \\This repository requires version {} or higher.
            \\
            \\Please update your installed version via your system package manager.
            \\
            \\
        ;
        @compileError(std.fmt.comptimePrint(error_message, .{min_zig}));
    }
}

pub fn build(b: *Build) !void {
    // remove the standard 'install' and 'uninstall' steps
    b.top_level_steps = .{};

    // i.e. `zig build -Dexample=[name]`
    b.default_step = b.step("example", "Run example");

    const example_run = ExampleStep.create(b);
    b.default_step.dependOn(&example_run.step);

    // zig build test
    const test_step = b.step("test", "Run all examples");
    inline for (std.meta.fields(Selection)) |selection| {
        // this fixes `panic: Option 'target' declared twice`
        b.available_options_map.clearRetainingCapacity();
        b.available_options_list.clearRetainingCapacity();

        const example = Example.init(b, @enumFromInt(selection.value));
        const test_run = b.addTest(.{
            .name = "example test",
            .target = example.target,
            .root_source_file = example.root_source_file,
        });
        test_step.dependOn(&test_run.step);
    }

    // zig build clean
    const clean_step = b.step("clean", "Clean temporary directories");
    if (builtin.os.tag != .windows) {
        clean_step.dependOn(&b.addRemoveDirTree(b.cache_root.path.?).step);
    }
}

const ExampleStep = struct {
    /// The main step, meant to be depended on by another step.
    step: Step,
    /// The `Allocator` from `step.owner.allocator`.
    allocator: Allocator,
    /// All information and build steps related to the selected example.
    example: Example,

    const Self = @This();

    pub fn create(b: *Build) *Self {
        const step = Step.init(.{
            .id = .custom,
            .makeFn = make,
            .name = "example step",
            .owner = b,
        });

        const selected_example = b.option(Selection, "example", "Run example") orelse .assignment;
        const example = Example.init(b, selected_example);

        const self = b.allocator.create(Self) catch @panic("OOM");
        self.* = .{
            .step = step,
            .allocator = b.allocator,
            .example = example,
        };

        return self;
    }

    fn make(step: *Step, prog_node: std.Progress.Node) !void {
        const self: *Self = @alignCast(@fieldParentPtr("step", step));

        const exe_path = try self.compile(prog_node);
        const result = try self.run(exe_path.?);

        printResult(&result);
    }

    fn compile(self: *Self, prog_node: std.Progress.Node) !?[]const u8 {
        const b = self.step.owner;
        const example = self.example;

        const cmd = example.getZigCmd();
        const src_path = example.getPath();
        const src_display = example.getDisplayName();
        const target = example.getZigTriple();
        const optimize = example.getOptimizeModeStr();

        var argv = std.ArrayList([]const u8).init(self.allocator);
        defer argv.deinit();

        argv.appendSlice(&.{
            b.graph.zig_exe,
            cmd,
            src_path,
            "-target",
            target,
            "-O",
            optimize,
            "--listen=-",
        }) catch @panic("OOM");

        // Use the provided libc file (if applicable),
        if (b.libc_file) |libc_file| {
            argv.appendSlice(&.{ "--libc", libc_file }) catch @panic("OOM");
        }
        // or manually provide it for FreeBSD targets.
        else if (builtin.os.tag == .freebsd) {
            var child = Child.init(&.{ b.graph.zig_exe, "libc" }, b.allocator);
            child.stdout_behavior = .Pipe;

            _ = try child.spawn();

            // dupe the stdout fd so we have an open one after 'child.wait()'
            const fd = try std.posix.dup(child.stdout.?.handle);

            _ = try child.wait();

            const fd_path = b.fmt("/dev/fd/{d}", .{fd});
            argv.appendSlice(&.{ "--libc", fd_path }) catch @panic("OOM");
        }

        if (example.extra_args) |args| argv.appendSlice(args) catch @panic("OOM");

        const fmt =
            \\{s}Running Zig process:{s}
            \\
            \\  Zig path:  {s}
            \\  Command:   {s}
            \\  Source:    {s}
            \\  Target:    {s}
            \\  Mode:      {s}
            \\  Flags:     
        ;
        print(fmt, .{ bold_ul, reset, b.graph.zig_exe, cmd, src_display, target, optimize });
        if (example.extra_args) |args| {
            for (args) |arg| print("{s} ", .{arg});
        }
        print("\n\n\n", .{});

        return self.step.evalZigProcess(argv.items, prog_node);
    }

    fn run(self: *Self, exe_path: []const u8) !Child.RunResult {
        const b = self.step.owner;

        var argv: []const []const u8 = undefined;
        if (self.example.run_step_cmd) |cmd|
            switch (builtin.os.tag) {
                .freebsd, .linux, .macos => {
                    argv = &.{ "bash", "-c", cmd, exe_path };
                },
                .windows => {
                    const cmd_fmt = b.fmt("& {{& '{s}' \"{s}\"}}", .{ cmd, exe_path });
                    argv = &.{ "powershell", "-Command", cmd_fmt };
                },
                else => @panic("Not implemented."),
            }
        else
            argv = &.{exe_path};

        // Allow 1MB of stdout capture
        const max_output_bytes = 1 * 1024 * 1024;

        return Child.run(.{
            .allocator = self.allocator,
            .argv = argv,
            .max_output_bytes = max_output_bytes,
        }) catch |err| {
            return self.step.fail("unable to spawn {s}: {s}", .{ argv[0], @errorName(err) });
        };
    }

    fn printResult(result: *const Child.RunResult) void {
        const default = "No content.\n";
        const stderr = if (result.stderr.len > 0) result.stderr else default;
        const stdout = if (result.stdout.len > 0) result.stdout else default;

        printStdio(stderr, stdout);
    }

    fn printStdio(stderr: []const u8, stdout: []const u8) void {
        if (std.io.getStdErr().getOrEnableAnsiEscapeSupport()) setColors();

        print(
            "{s}Debug Logs ({s}stderr{s}):{s}\n\n{s}\n\n",
            .{ bold_ul, fg_red, fg_gray, reset, stderr },
        );
        print(
            "{s}Program Output ({s}stdout{s}):{s}\n\n{s}\n",
            .{ bold_ul, fg_green, fg_gray, reset, stdout },
        );
    }

    fn setColors() void {
        reset = "\x1b[0m";
        bold_ul = "\x1b[1;4m";
        fg_red = "\x1b[31m";
        fg_green = "\x1b[32m";
        fg_gray = "\x1b[37m";
    }
};

var reset: []const u8 = "";
var bold_ul: []const u8 = "";
var fg_red: []const u8 = "";
var fg_green: []const u8 = "";
var fg_gray: []const u8 = "";

const Chapters = [_]type{
    LanguageBasics,
    StandardLibrary,
    BuildSystem,
    CInterop,
};

const LanguageBasics = enum {
    assignment,
    arrays,
    @"if",
    while_loop,
    for_loop,
    errors,
    @"defer",
    functions,
    @"switch",
    runtime_safety,
    @"unreachable",
    pointers,
    pointer_sized_ints,
    many_item_pointers,
    slices,
    enums,
    structs,
    unions,
    integer_rules,
    floats,
    labelled_blocks,
    labelled_loops,
    loops_as_expressions,
    optionals,
    @"comptime",
    @"opaque",
    anonymous_structs,
    sentinel_termination,
    vectors,
    imports,
};

const StandardLibrary = enum {
    allocators,
    ArrayList,
    filesystem,
    readers_and_writers,
    formatting,
    JSON,
    random_numbers,
    crypto,
    threads,
    hash_maps,
    stacks,
    sorting,
    iterators,
    formatting_specifiers,
    advanced_formatting,
};

const BuildSystem = enum {
    emit_an_executable,
    cross_compilation,
};

const CInterop = enum {};

const Selection = @Type(Type{
    .Enum = .{
        .decls = &.{},
        .fields = blk: {
            var len: u16 = 0;
            for (Chapters) |chapter| len += meta.fields(chapter).len;

            var fields: [len]Type.EnumField = undefined;
            var idx: u16 = 0;
            for (Chapters) |chapter| {
                const examples = meta.fields(chapter);
                for (examples) |example| {
                    fields[idx] = .{ .name = example.name, .value = idx };
                    idx += 1;
                }
            }

            break :blk &fields;
        },
        .is_exhaustive = true,
        .tag_type = u8,
    },
});
const Kind = enum {
    exe,
    @"test",
};
const Example = struct {
    builder: *Build,
    allocator: Allocator,
    selection: Selection,
    kind: Kind = .@"test",

    root_source_file: LazyPath,
    target: Build.ResolvedTarget,
    optimize: OptimizeMode,
    extra_args: ?[]const []const u8 = null,
    run_step_cmd: ?[]const u8 = null,

    const Self = @This();

    pub fn init(b: *Build, selection: Selection) Self {
        var self = Self{
            .builder = b,
            .allocator = b.allocator,
            .selection = selection,

            .root_source_file = Self.getRootLazyPath(b, selection),
            .target = b.standardTargetOptions(.{}),
            .optimize = b.standardOptimizeOption(.{}),
        };

        switch (self.selection) {
            // Examples from: 01 Language Basics/
            .assignment, // 01
            => {
                self.kind = .exe;
            },
            // Examples from: 03 Build System/
            .emit_an_executable => { // 01
                self.kind = .exe;
                self.optimize = OptimizeMode.ReleaseSafe;
                self.extra_args = &.{ "-fstrip", "-fsingle-threaded" };
            },
            .cross_compilation => { // 02
                self.kind = .exe;
                self.target = b.resolveTargetQuery(.{
                    .cpu_arch = .aarch64,
                });
                self.run_step_cmd = blk: {
                    switch (builtin.os.tag) {
                        .freebsd, .linux, .macos => {
                            break :blk "set -x; file \"$0\"";
                        },
                        .windows => {
                            const env = "PROGRAMFILES";
                            const prefix = std.process.getEnvVarOwned(b.allocator, env) catch @panic("OOM");
                            break :blk b.pathJoin(&.{ prefix, "Git", "usr", "bin", "file" });
                        },
                        else => @panic("Not implemented"),
                    }
                };
            },
            // Everything else is assumed to be a test with the standard options.
            else => {},
        }

        return self;
    }

    fn getRootLazyPath(b: *Build, selection: Selection) LazyPath {
        inline for (Chapters) |chapter| {
            if (meta.fields(chapter).len == 0) continue;
            if (meta.stringToEnum(chapter, @tagName(selection))) |ex_name| {
                const id = @intFromEnum(ex_name) + @as(u32, 1);
                const name = @tagName(ex_name);
                const dir = switch (chapter) {
                    LanguageBasics => "01 Language Basics",
                    StandardLibrary => "02 Standard Library",
                    BuildSystem => "03 Build System",
                    CInterop => "04 C Interoperability",
                    else => std.debug.panic("Invalid chapter: {s}\n", .{@typeName(chapter)}),
                };
                const fmt = "examples/" ++ dir ++ "/{d:0>2} {s}.zig";
                return b.path(b.fmt(fmt, .{ id, name }));
            }
        }
        unreachable;
    }

    fn getZigCmd(self: Self) []const u8 {
        return switch (self.kind) {
            .exe => "build-exe",
            .@"test" => "test",
        };
    }

    /// Returns an absolute path.
    /// Intended to be used during the make phase only.
    fn getPath(self: Self) []const u8 {
        return self.root_source_file.getPath(self.builder);
    }

    /// Returns the string that can be shown to represent the source.
    /// Either returns the path, "generated", or "dependency".
    fn getDisplayName(self: Self) []const u8 {
        return self.root_source_file.getDisplayName();
    }

    /// Returns the string representation of the `target` field in the Zig format.
    fn getZigTriple(self: Self) []const u8 {
        return self.target.result.zigTriple(self.builder.allocator) catch @panic("OOM");
    }

    /// Returns the string representation of the `optimize` field.
    fn getOptimizeModeStr(self: Self) []const u8 {
        return @tagName(self.optimize);
    }
};
