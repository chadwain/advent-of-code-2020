const std = @import("std");
const puzzle_input = @embedFile("input12");

pub fn main() void {
    part1();
    part2();
}

fn part1() void {
    var pos = Pos{
        .x = 0,
        .y = 0,
        .dir = .E,
    };

    var it = std.mem.tokenize(puzzle_input, "\n");
    while (it.next()) |inst| {
        const dir_str = inst[0];
        const unit = std.fmt.parseUnsigned(u16, inst[1..], 10) catch unreachable;

        const dir: Dir = switch (dir_str) {
            'N' => .N,
            'E' => .E,
            'S' => .S,
            'W' => .W,
            'F' => pos.dir,
            else => {
                pos.dir = switch (dir_str) {
                    'L' => pos.dir.rotate(-@intCast(i3, @divExact(unit, 90))),
                    'R' => pos.dir.rotate(@intCast(i3, @divExact(unit, 90))),
                    else => unreachable,
                };
                continue;
            },
        };

        pos.move(unit, dir);
    }

    std.debug.print("Part 1 Ship ending position: ({}, {}) facing {}\n", .{ pos.x, pos.y, @tagName(pos.dir) });
}

fn part2() void {
    var waypoint = Pos{
        .x = 10,
        .y = 1,
        .dir = undefined,
    };
    var ship = Pos{
        .x = 0,
        .y = 0,
        .dir = undefined,
    };

    var it = std.mem.tokenize(puzzle_input, "\n");
    while (it.next()) |inst| {
        const dir_str = inst[0];
        const unit = std.fmt.parseUnsigned(u16, inst[1..], 10) catch unreachable;

        const dir: Dir = switch (dir_str) {
            'N' => .N,
            'E' => .E,
            'S' => .S,
            'W' => .W,
            else => {
                switch (dir_str) {
                    'L' => waypoint.rotate(-@intCast(i3, @divExact(unit, 90))),
                    'R' => waypoint.rotate(@intCast(i3, @divExact(unit, 90))),
                    'F' => {
                        ship.move(waypoint.x * unit, .E);
                        ship.move(waypoint.y * unit, .N);
                    },
                    else => unreachable,
                }
                continue;
            },
        };

        waypoint.move(unit, dir);
    }

    std.debug.print("Part 2 Ship ending position: ({}, {})\n", .{ ship.x, ship.y });
    std.debug.print("Part 2 Waypoint ending position: ({}, {})\n", .{ waypoint.x, waypoint.y });
}

const Dir = enum {
    const Self = @This();

    N,
    E,
    S,
    W,

    fn rotate(self: Self, cw_turns: i3) Self {
        return @intToEnum(Self, @intCast(u2, @mod(@enumToInt(self) + @as(i4, cw_turns), 4)));
    }
};

const Pos = struct {
    const Self = @This();

    x: i32,
    y: i32,
    dir: Dir,

    fn move(self: *Self, unit: i32, dir: Dir) void {
        switch (dir) {
            .N => self.y += unit,
            .E => self.x += unit,
            .S => self.y -= unit,
            .W => self.x -= unit,
        }
    }

    fn rotate(self: *Self, cw_turns: i3) void {
        const complex: [2]i32 = switch (cw_turns) {
            0, -4 => .{ 1, 0 },
            1, -3 => .{ 0, -1 },
            2, -2 => .{ -1, 0 },
            3, -1 => .{ 0, 1 },
        };
        const x = self.x;
        const y = self.y;
        self.x = x * complex[0] - y * complex[1];
        self.y = x * complex[1] + y * complex[0];
    }
};
