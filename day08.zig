const std = @import("std");
const print = std.debug.print;

pub fn main() void {
    comptime const puzzle_input = @embedFile("input08");

    @setEvalBranchQuota(700000);
    comptime const num_instructions = blk: {
        var count: usize = 0;
        for (puzzle_input) |c| {
            if (c == '\n') count += 1;
        }
        break :blk count;
    };
    comptime var instructions = comptime blk: {
        var result: [num_instructions]Instruction = undefined;

        var byLine = std.mem.tokenize(puzzle_input, "\n");
        var i: usize = 0;
        while (byLine.next()) |line| {
            result[i] = Instruction.fromLine(line);
            i += 1;
        }

        break :blk result;
    };

    comptime const loopingInstruction = runProgram(num_instructions, &instructions).infiniteLoop;

    comptime const brokenInstruction = comptime for (instructions) |*inst, index| {
        const old_op = inst.op;
        inst.op = switch (old_op) {
            .acc => continue,
            .jmp => .nop,
            .nop => .jmp,
        };
        defer inst.op = old_op;

        const programResult = runProgram(num_instructions, &instructions);
        switch (programResult) {
            .success => |acc| break .{ .index = index, .accumulator = acc },
            .infiniteLoop => continue,
        }
    } else unreachable;

    print("the program loops at instruction {}\naccumulator was {}\n", .{ loopingInstruction.index, loopingInstruction.accumulator });
    print("the broken instruction was instruction {}\naccumulator is now {}\n", .{ brokenInstruction.index, brokenInstruction.accumulator });

    //// This is what would be the solution if I didn't decide to brute force instead.
    //    {
    //        var changed_one: bool = false;
    //        var index: i32 = num_instructions - 1;
    //        main_loop: while (index > 0) {
    //            const current = instructions[@intCast(usize, index)];
    //            print("{}: {} {}\n", .{ index, @tagName(current.op), current.arg });
    //            const previous = instructions[@intCast(usize, index) - 1];
    //            if (previous.op != .jmp or (previous.op == .jmp and previous.arg == 1)) {
    //                index -= 1;
    //                continue :main_loop;
    //            } else {
    //                for (instructions) |inst, i| {
    //                    if (i == index) continue;
    //                    if (inst.op == .jmp and @intCast(i16, i) + inst.arg == index) {
    //                        index = @intCast(i16, i);
    //                        continue :main_loop;
    //                    }
    //                }
    //                if (!changed_one) {
    //                    for (instructions) |inst, i| {
    //                        if (i == index) continue;
    //                        if (inst.op == .nop and @intCast(i16, i) + inst.arg == index) {
    //                            changed_one = true;
    //                            print("changed instruction {} from nop to jmp\n", .{i});
    //                            instructions[i].op = .jmp;
    //                            index = @intCast(i16, i);
    //                            continue :main_loop;
    //                        }
    //                    }
    //
    //                    if (previous.op == .jmp) {
    //                        changed_one = true;
    //                        print("changed instruction {} from jmp to nop\n", .{index - 1});
    //                        instructions[@intCast(usize, index - 1)].op = .nop;
    //                        index -= 1;
    //                        continue :main_loop;
    //                    }
    //                }
    //                unreachable;
    //            }
    //        }
    //    }
}

const Instruction = struct {
    const Self = @This();
    const Op = enum { acc, jmp, nop };

    op: Op,
    arg: i16,

    fn fromLine(comptime str: []const u8) Self {
        const eql = std.mem.eql;
        const op = if (eql(u8, str[0..3], "acc")) .acc else if (eql(u8, str[0..3], "jmp")) .jmp else if (eql(u8, str[0..3], "nop")) .nop;
        return Self{
            .op = op,
            .arg = std.fmt.parseInt(i16, str[4..], 10) catch unreachable,
        };
    }
};

fn runProgram(comptime count: comptime_int, instructions: *[count]Instruction) (union(enum) { success: i16, infiniteLoop: struct { index: u16, accumulator: i16 } }) {
    var was_executed = blk: {
        var result: [count]bool = undefined;
        for (result) |*b| b.* = false;
        break :blk result;
    };
    var accumulator: i16 = 0;
    var inst_pointer: u16 = 0;
    while (inst_pointer < count) {
        if (was_executed[inst_pointer] == true) return .{ .infiniteLoop = .{ .index = inst_pointer, .accumulator = accumulator } };
        was_executed[inst_pointer] = true;

        const inst = instructions[inst_pointer];
        switch (inst.op) {
            .acc => {
                accumulator += inst.arg;
                inst_pointer += 1;
            },
            .jmp => {
                inst_pointer = @intCast(u16, @intCast(i16, inst_pointer) + inst.arg);
            },
            .nop => {
                inst_pointer += 1;
            },
        }
    }

    return .{ .success = accumulator };
}
