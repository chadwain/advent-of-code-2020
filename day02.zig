const std = @import("std");

pub fn main() !void {
    const puzzle_input = @embedFile("input02");
    std.debug.print("Part 1: {}\nPart 2: {}\n", .{ solve(puzzle_input, Password.followsOldPolicy), solve(puzzle_input, Password.followsNewPolicy) });
}

const Password = struct {
    min: u8,
    max: u8,
    letter: u8,
    string: []const u8,

    fn followsOldPolicy(self: @This()) bool {
        var count: u8 = 0;
        for (self.string) |c| {
            if (c == self.letter) count += 1;
        }
        return count >= self.min and count <= self.max;
    }

    fn followsNewPolicy(self: @This()) bool {
        return (self.letter == self.string[self.min - 1]) != (self.letter == self.string[self.max - 1]);
    }
};

fn solve(input: []const u8, comptime policyFn: fn (Password) bool) usize {
    var count: usize = 0;

    var index: usize = 0;
    while (index < input.len) {
        const password = nextPassword(input, &index);
        if (policyFn(password)) count += 1;
    }

    return count;
}

fn nextPassword(input: []const u8, start_index: *usize) Password {
    const find = std.mem.indexOfScalarPos;
    const parse = std.fmt.parseUnsigned;

    var index = start_index.*;

    const dash_index = find(u8, input, index, '-').?;
    const min = parse(u8, input[index..dash_index], 10) catch unreachable;
    index = dash_index + 1;

    const space_index = find(u8, input, index, ' ').?;
    const max = parse(u8, input[index..space_index], 10) catch unreachable;
    index = space_index + 1;

    const letter = input[index];

    const newline_index = find(u8, input, index, '\n').?;
    const string = input[index + 3 .. newline_index];
    index = newline_index + 1;

    start_index.* = index;
    return .{
        .min = min,
        .max = max,
        .letter = letter,
        .string = string,
    };
}
