const std = @import("std");

pub fn main() void {
    comptime const puzzle_input = @embedFile("input03");
    comptime const grid_width = std.mem.indexOfScalar(u8, puzzle_input, '\n').?;
    comptime const grid_height = @divExact(puzzle_input.len, grid_width + 1);
    std.debug.print("width: {}, height: {}\n", .{ grid_width, grid_height });

    comptime const part1 = numTreesHit(puzzle_input, grid_width, grid_height, 3, 1);
    std.debug.print("Part 1:\n\tnumber of trees: {}\n", .{part1});

    const slopes = .{
        .{ .delta_x = 1, .delta_y = 1 },
        .{ .delta_x = 3, .delta_y = 1 },
        .{ .delta_x = 5, .delta_y = 1 },
        .{ .delta_x = 7, .delta_y = 1 },
        .{ .delta_x = 1, .delta_y = 2 },
    };

    std.debug.print("Part 2:\n", .{});
    comptime var part2: usize = 1;
    inline for (slopes) |slope, i| {
        @setEvalBranchQuota(3210);
        comptime const trees = numTreesHit(puzzle_input, grid_width, grid_height, slope.delta_x, slope.delta_y);
        std.debug.print("\t{}: {}\n", .{ i, trees });
        part2 *= trees;
    }
    std.debug.print("\tProduct: {}\n", .{part2});
}

fn numTreesHit(grid: []const u8, grid_width: usize, grid_height: usize, delta_x: usize, delta_y: usize) usize {
    var tree_count: usize = 0;
    var x: usize = 0;
    var y: usize = 0;
    while (y < grid_height) : ({
        x += delta_x;
        y += delta_y;
    }) {
        const x_mod = (x + (x / grid_width)) % (grid_width + 1);
        const cell = grid[x_mod + y * (grid_width + 1)];
        if (cell == '#') tree_count += 1;
    }
    return tree_count;
}
