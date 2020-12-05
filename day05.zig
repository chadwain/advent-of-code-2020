const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    const puzzle_input = @embedFile("input05");

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var seat_ids = std.ArrayList(u16).init(&arena.allocator);
    defer seat_ids.deinit();

    var byLine = std.mem.tokenize(puzzle_input, "\n");
    var i: usize = 0;
    while (byLine.next()) |line| {
        const pos = getRowAndColumn(line);
        const seat_id = @as(u16, pos.row) * 8 + pos.column;
        try seat_ids.append(seat_id);
        print("{}: {} row {} column {} id {}\n", .{ i, line, pos.row, pos.column, seat_id });
        i += 1;
    }

    std.sort.sort(u16, seat_ids.items, {}, comptime std.sort.asc(u16));
    print("highest seat id: {}\n", .{seat_ids.items[seat_ids.items.len - 1]});

    for (seat_ids.items[0 .. seat_ids.items.len - 1]) |id, n| {
        if (seat_ids.items[n + 1] - id == 2) print("maybe it's your seat! {}\n", .{id + 1});
    }
}

fn getRowAndColumn(str: []const u8) (struct { row: u7, column: u3 }) {
    var row: u7 = 0;
    for (str[0..7]) |c, i| {
        const bit: u1 = switch (c) {
            'F' => 0,
            'B' => 1,
            else => unreachable,
        };
        row |= (@as(u7, 1) << (6 - @intCast(u3, i))) * bit;
    }
    var column: u3 = 0;
    for (str[7..10]) |c, i| {
        const bit: u1 = switch (c) {
            'L' => 0,
            'R' => 1,
            else => unreachable,
        };
        column |= (@as(u3, 1) << (2 - @intCast(u2, i))) * bit;
    }
    return .{ .row = row, .column = column };
}
