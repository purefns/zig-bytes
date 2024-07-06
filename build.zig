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
};

const Chapters = [_]type{
    LanguageBasics,
    StandardLibrary,
    BuildSystem,
    CInterop,
};

const LanguageBasics = enum {
    assignment,
    arrays,
    if_statement,
    while_loop,
    for_loop,
    functions,
    @"defer",
    errors,
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
    kind: Kind = .exe,

    root_source_file: LazyPath,
    target: Build.ResolvedTarget,
    optimize: OptimizeMode,
    extra_args: ?[]const []const u8 = null,

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
            .if_statement, // 03
            .while_loop, // 04
            .functions, // 06
            => {
                self.kind = .@"test";
            },
            // Examples from: 03 Build System/
            .emit_an_executable => { // 01
                self.optimize = OptimizeMode.ReleaseSafe;
                self.extra_args = &.{ "-fstrip", "-fsingle-threaded" };
            },
            .cross_compilation => { // 02
                self.target = b.resolveTargetQuery(.{
                    .cpu_arch = .aarch64,
                });
            },
            // Everything else is assumed to be an executable with the standard options.
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
};
