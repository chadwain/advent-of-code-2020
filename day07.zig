const std = @import("std");
const print = std.debug.print;
const Allocator = std.mem.Allocator;
const ArrayListUnmanaged = std.ArrayListUnmanaged;

pub fn main() !void {
    const puzzle_input = @embedFile("input07");
    const num_rules = std.mem.count(u8, puzzle_input, "\n");

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = &arena.allocator;

    var input_set = try InputSet(Rule).init(allocator, num_rules);
    defer input_set.deinit(allocator);

    var byLines = std.mem.tokenize(puzzle_input, "\n");
    var i: usize = 0;
    while (byLines.next()) |line| {
        const rule = Rule.fromString(line);
        input_set.items[i].value = rule;
        i += 1;
    }

    var input_set_2 = try input_set.clone(allocator);
    defer input_set_2.deinit(allocator);

    const part1answer = try part1(allocator, &input_set);
    const part2answer = try part2(allocator, &input_set_2);

    print("part 1 answer: {}\n", .{part1answer});
    print("part 2 answer: {}\n", .{part2answer});
}

fn part1(allocator: *Allocator, input_set: *InputSet(Rule)) !usize {
    const num_rules = input_set.items.len;
    var list1 = try ArrayListUnmanaged(Rule).initCapacity(allocator, num_rules);
    defer list1.deinit(allocator);
    var list2 = try ArrayListUnmanaged(Rule).initCapacity(allocator, num_rules);
    defer list2.deinit(allocator);

    var src = &list1;
    var dest = &list2;

    var total_removed: usize = 0;
    {
        var set_it = input_set.iterator();
        while (set_it.next()) |v| {
            const rule = v.value;
            if (rule.contains("shiny", "gold")) {
                _ = input_set.remove(v.index);
                src.appendAssumeCapacity(rule);
                total_removed += 1;
                rule.printRule();
            }
        }
    }
    print("removed {}\ntotal {}\n\n", .{ total_removed, total_removed });

    while (src.items.len > 0) : ({
        src.items.len = 0;
        std.mem.swap(*ArrayListUnmanaged(Rule), &src, &dest);
    }) {
        var set_it = input_set.iterator();
        set_loop: while (set_it.next()) |v| {
            const rule = v.value;
            for (src.items) |src_bag| {
                if (rule.contains(src_bag.container.style, src_bag.container.color)) {
                    _ = input_set.remove(v.index);
                    dest.appendAssumeCapacity(rule);
                    rule.printRule();
                    continue :set_loop;
                }
            }
        }

        total_removed += dest.items.len;
        print("removed {}\ntotal {}\n\n", .{ dest.items.len, total_removed });
    }

    return total_removed;
}

fn part2(allocator: *Allocator, input_set: *InputSet(Rule)) !usize {
    const num_rules = input_set.items.len;
    var list1 = try ArrayListUnmanaged(Rule.Contained).initCapacity(allocator, num_rules);
    defer list1.deinit(allocator);
    var list2 = try ArrayListUnmanaged(Rule.Contained).initCapacity(allocator, num_rules);
    defer list2.deinit(allocator);

    var src = &list1;
    var dest = &list2;

    var total_bags: usize = 0;
    {
        for (input_set.items) |v| {
            const rule = v.value;
            if (rule.is("shiny", "gold")) {
                rule.printRule();
                for (rule.contained[0..rule.num_contained]) |contained| {
                    src.appendAssumeCapacity(contained);
                }
                break;
            }
        }
    }
    print("added {0}\ntotal {0}\n\n", .{total_bags});

    while (src.items.len > 0) : ({
        src.items.len = 0;
        std.mem.swap(*ArrayListUnmanaged(Rule.Contained), &src, &dest);
    }) {
        var bag_count: usize = 0;
        for (src.items) |src_bag| {
            bag_count += src_bag.number;

            var src_rule: Rule = undefined;
            for (input_set.items) |v| {
                if (v.value.is(src_bag.style, src_bag.color)) {
                    src_rule = v.value;
                }
            }
            src_rule.printRule();

            for (src_rule.contained[0..src_rule.num_contained]) |bag| {
                var copy = bag;
                copy.number *= src_bag.number;
                dest.appendAssumeCapacity(copy);
            }
        }

        total_bags += bag_count;
        print("added {}\ntotal {}\n\n", .{ bag_count, total_bags });
    }

    return total_bags;
}

const Rule = struct {
    const Self = @This();
    const Contained = struct { number: u64, style: []const u8, color: []const u8 };

    container: struct { style: []const u8, color: []const u8 },
    contained: [4]Contained,
    num_contained: u3,

    fn fromString(line: []const u8) Self {
        var words = std.mem.tokenize(line, " ");

        var self: Self = undefined;
        self.num_contained = 0;
        self.container.style = words.next().?;
        self.container.color = words.next().?;
        _ = words.next().?;
        _ = words.next().?;

        while (words.next()) |numberStr| {
            const sub_bag = &self.contained[self.num_contained];
            sub_bag.number = std.fmt.parseUnsigned(u8, numberStr, 10) catch {
                std.debug.assert(self.num_contained == 0);
                break;
            };
            sub_bag.style = words.next().?;
            sub_bag.color = words.next().?;
            _ = words.next().?;
            self.num_contained += 1;
        }

        return self;
    }

    fn is(self: Self, style: []const u8, color: []const u8) bool {
        return std.mem.eql(u8, style, self.container.style) and std.mem.eql(u8, color, self.container.color);
    }

    fn contains(self: Self, style: []const u8, color: []const u8) bool {
        for (self.contained[0..self.num_contained]) |bag| {
            if (std.mem.eql(u8, style, bag.style) and std.mem.eql(u8, color, bag.color)) return true;
        }
        return false;
    }

    fn printRule(self: Self) void {
        print("{} {} => ", .{ self.container.style, self.container.color });
        for (self.contained[0..self.num_contained]) |c| {
            print("{} {} {}, ", .{ c.number, c.style, c.color });
        }
        print("\n", .{});
    }
};

/// Wraps an array into a doubly linked list
fn InputSet(comptime V: type) type {
    return struct {
        const Self = @This();
        const Element = struct {
            value: V,
            prev: ?usize,
            next: ?usize,
        };

        items: []Element,
        first: ?usize = 0,

        fn init(allocator: *Allocator, count: usize) !Self {
            const items = try allocator.alloc(Element, count);
            items[0].prev = null;
            items[0].next = 1;
            items[count - 1].prev = count - 2;
            items[count - 1].next = null;

            var i: usize = 1;
            while (i < count - 1) : (i += 1) {
                const item = &items[i];
                item.prev = i - 1;
                item.next = i + 1;
            }
            return Self{ .items = items };
        }

        fn deinit(self: *Self, allocator: *Allocator) void {
            allocator.free(self.items);
        }

        fn remove(self: *Self, index: usize) V {
            const elem = &self.items[index];
            if (elem.prev) |p| self.items[p].next = elem.next else self.first = elem.next;
            if (elem.next) |n| self.items[n].prev = elem.prev;
            elem.next = null;
            elem.prev = null;
            return elem.value;
        }

        fn clone(self: Self, allocator: *Allocator) !Self {
            return Self{ .items = try std.mem.dupe(allocator, Element, self.items), .first = self.first };
        }

        const Iterator = struct {
            items: []Element,
            next_index: ?usize,

            const NextResult = struct { value: V, index: usize };

            fn next(self: *@This()) ?NextResult {
                const next_index = self.next_index orelse return null;
                const elem = self.items[next_index];
                self.next_index = elem.next;
                return NextResult{ .value = elem.value, .index = next_index };
            }
        };

        fn iterator(self: Self) Iterator {
            return Iterator{ .items = self.items, .next_index = self.first };
        }
    };
}
