const std = @import("std");
const print = std.debug.print;
const puzzle_input = @embedFile("input06");

pub fn main() void {
    print("part 1: {}\npart 2: {}\n", .{ part1(), part2() });
}

fn part1() u32 {
    var sum: u32 = 0;
    var it = std.mem.split(puzzle_input, "\n\n");
    while (it.next()) |group| {
        var answers: u26 = 0;
        for (group) |c| {
            if (c == '\n') continue;
            answers |= @as(u26, 1) << @intCast(u5, c - 'a');
        }
        const numberOfYes = @popCount(u26, answers);
        sum += numberOfYes;
    }
    return sum;
}

fn part2() u32 {
    var sum: u32 = 0;
    var it = std.mem.split(puzzle_input, "\n\n");
    while (it.next()) |group| {
        var allYes: u26 = std.math.maxInt(u26);
        var people = std.mem.split(group, "\n");
        while (people.next()) |person| {
            if (person.len == 0) continue;
            var answers: u26 = 0;
            for (person) |c| {
                answers |= @as(u26, 1) << @intCast(u5, c - 'a');
            }
            allYes &= answers;
        }
        const numberOfAllYes = @popCount(u26, allYes);
        sum += numberOfAllYes;
    }
    return sum;
}
