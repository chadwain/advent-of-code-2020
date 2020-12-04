const std = @import("std");
const print = std.debug.print;

const InputDataIterator = struct {
    data: []const u8 = @embedFile("input04"),

    fn next(self: *@This()) ?[]const u8 {
        const passport_end_index = blk: {
            var newline_index = std.mem.indexOfScalarPos(u8, self.data, 0, '\n') orelse return null;
            while (newline_index + 1 < self.data.len) {
                if (self.data[newline_index + 1] == '\n') break :blk newline_index;
                newline_index = std.mem.indexOfScalarPos(u8, self.data, newline_index + 1, '\n').?;
            }
            break :blk newline_index;
        };
        const result = self.data[0..passport_end_index];
        const new_start_index = passport_end_index + 1 + @boolToInt(passport_end_index + 1 < self.data.len);
        self.data = self.data[new_start_index..];
        return result;
    }
};

const PassportData = struct {
    birth_year: []const u8 = "",
    issue_year: []const u8 = "",
    exp_year: []const u8 = "",
    height: []const u8 = "",
    hair_color: []const u8 = "",
    eye_color: []const u8 = "",
    passport_id: []const u8 = "",

    fn fillData(self: *@This(), key: []const u8, value: []const u8) bool {
        if (std.mem.eql(u8, "byr", key)) {
            self.birth_year = value;
            return true;
        } else if (std.mem.eql(u8, "iyr", key)) {
            self.issue_year = value;
            return true;
        } else if (std.mem.eql(u8, "eyr", key)) {
            self.exp_year = value;
            return true;
        } else if (std.mem.eql(u8, "hgt", key)) {
            self.height = value;
            return true;
        } else if (std.mem.eql(u8, "hcl", key)) {
            self.hair_color = value;
            return true;
        } else if (std.mem.eql(u8, "ecl", key)) {
            self.eye_color = value;
            return true;
        } else if (std.mem.eql(u8, "pid", key)) {
            self.passport_id = value;
            return true;
        } else return false;
    }

    fn isValid(self: @This()) bool {
        const parse = std.fmt.parseUnsigned;

        if (self.birth_year.len != 4) return false;
        const birth_year_num = parse(u16, self.birth_year, 10) catch return false;
        if (!(birth_year_num >= 1920 and birth_year_num <= 2002)) return false;

        if (self.issue_year.len != 4) return false;
        const issue_year_num = parse(u16, self.issue_year, 10) catch return false;
        if (!(issue_year_num >= 2010 and issue_year_num <= 2020)) return false;

        if (self.exp_year.len != 4) return false;
        const exp_year_num = parse(u16, self.exp_year, 10) catch return false;
        if (!(exp_year_num >= 2020 and exp_year_num <= 2030)) return false;

        if (self.height.len < 4) return false;
        const unit = self.height[self.height.len - 2 ..];
        const height_num = parse(u16, self.height[0 .. self.height.len - 2], 10) catch return false;
        const valid_cm = (std.mem.eql(u8, "cm", unit) and height_num >= 150 and height_num <= 193);
        const valid_in = (std.mem.eql(u8, "in", unit) and height_num >= 59 and height_num <= 76);
        if (!(valid_cm or valid_in)) return false;

        if (self.hair_color.len != 7) return false;
        if (self.hair_color[0] != '#') return false;
        for (self.hair_color[1..]) |c| {
            if (!(c >= '0' and c <= '9') and !(c >= 'a' and c <= 'f')) return false;
        }

        if (self.eye_color.len != 3) return false;
        if (std.mem.indexOf(u8, "amb\u{0}blu\u{0}brn\u{0}gry\u{0}grn\u{0}hzl\u{0}oth", self.eye_color) == null) return false;

        if (self.passport_id.len != 9) return false;
        _ = parse(u64, self.passport_id, 10) catch return false;

        return true;
    }

    fn passport_print(self: @This()) void {
        print("Passport {{\n", .{});
        inline for (std.meta.fields(@This())) |field| {
            print("\t{}:{}\n", .{ field.name, @field(self, field.name) });
        }
        print("}}\n\n", .{});
    }
};

pub fn main() void {
    var passport_count: usize = 0;
    var filled_passports: usize = 0;
    var valid_passports: usize = 0;

    var it = InputDataIterator{};
    while (it.next()) |passport| {
        var passport_data = PassportData{};
        var key_count: usize = 0;

        var fields = std.mem.tokenize(passport, " \n");
        while (fields.next()) |field| {
            const key = field[0..3];
            const value = field[4..];
            key_count += @boolToInt(passport_data.fillData(key, value));
        }

        passport_count += 1;
        if (key_count >= 7) {
            filled_passports += 1;
            valid_passports += @boolToInt(passport_data.isValid());
        }
        passport_data.passport_print();
    }

    print(
        "Number of Passports: {}\nNumber of filled passports: {}\nNumber of valid passports: {}\n",
        .{ passport_count, filled_passports, valid_passports },
    );
}
