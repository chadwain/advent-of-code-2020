const std = @import("std");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    const input_data = blk: {
        const stdin = std.io.getStdIn();
        const data = try stdin.readToEndAlloc(allocator, 1024 * 1024);
        defer allocator.free(data);
        const integers = try parseInputData(allocator, data);
        std.sort.sort(u16, integers, {}, comptime std.sort.asc(u16));
        break :blk integers;
    };
    defer allocator.free(input_data);

    const product2 = getProductOf2(input_data) orelse {
        std.debug.print("Part 1 failed.\n", .{});
        return error.InvalidData;
    };
    const product3 = getProductOf3(input_data) orelse {
        std.debug.print("Part 2 failed.\n", .{});
        return error.InvalidData;
    };
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Part 1: {}\nPart 2: {}\n", .{ product2, product3 });
}

fn parseInputData(allocator: *std.mem.Allocator, data: []const u8) ![]u16 {
    var byLine = std.mem.split(data, "\n");

    var array = std.ArrayList(u16).init(allocator);
    errdefer array.deinit();

    while (byLine.next()) |line| {
        if (line.len == 0) break;
        const asInt = try std.fmt.parseUnsigned(u16, line, 10);
        try array.append(asInt);
    }

    return array.toOwnedSlice();
}

fn findIndeces(target: u16, input_data: []const u16) ?[2]usize {
    var i: usize = 0;
    return while (i < input_data.len - 1) : (i += 1) {
        const first = input_data[i];
        const second = std.math.sub(u16, target, first) catch return null;
        const indexOfSecond = blk: {
            const result = std.sort.binarySearch(u16, second, input_data[i + 1 ..], {}, order_u16) orelse continue;
            break :blk result + (i + 1);
        };
        break [2]usize{ i, indexOfSecond };
    } else null;
}

fn getProductOf2(input_data: []const u16) ?u32 {
    const indeces = findIndeces(2020, input_data) orelse return null;
    return @as(u32, input_data[indeces[0]]) * input_data[indeces[1]];
}

fn getProductOf3(input_data: []const u16) ?u48 {
    var i: usize = 0;
    return while (i < input_data.len - 2) : (i += 1) {
        const first = input_data[i];
        const indeces = blk: {
            var result = findIndeces(2020 - first, input_data[i + 1 ..]) orelse continue;
            for (result) |*v| v.* += i + 1;
            break :blk result;
        };
        break @as(u48, first) * input_data[indeces[0]] * input_data[indeces[1]];
    } else null;
}

fn order_u16(context: void, lhs: u16, rhs: u16) std.math.Order {
    return std.math.order(lhs, rhs);
}
