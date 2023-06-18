const std = @import("std");
const mem = std.mem;
const print = std.debug.print;

pub fn countWords(allocator: mem.Allocator, s: []const u8) !std.StringHashMap(u32) {
    var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    const gpa = general_purpose_allocator.allocator();
    var word = std.ArrayList(u8).init(gpa);
    defer word.deinit();
    errdefer word.deinit();

    var map = std.StringHashMap(u32).init(allocator);
    var wordEnded = false;
    print("\n", .{});
    for (s, 0..) |c, i| {
        // print("word: {s}\n", .{word.items});
        // print("items:{s} len:{} c:{c}:{}:{x} {}, wordEnded: {}\n", .{ word.items, word.items.len, if (c == '\n') 'N' else c, c, c, std.ascii.isAlphanumeric('\n'), wordEnded });
        // getLastOrNull
        // print("std.ascii.isAlphanumeric('\''):{}\n", .{std.ascii.isAlphanumeric('\'')});
        if (std.ascii.isAlphanumeric(c)) {
            try word.append(std.ascii.toLower(c));
            wordEnded = false;
        } else if (c == '\'' and i > 0 and i < s.len - 1) {
            const lastIsAlpha = if (word.getLastOrNull()) |l| std.ascii.isAlphabetic(l) else false;
            if (lastIsAlpha) {
                try word.append(c);
            } else {
                wordEnded = true;
            }
        } else {
            // print("else\n", .{});
            wordEnded = true;
            if (word.getLastOrNull()) |l| {
                if (l == '\'') {
                    _ = word.pop();
                }
            }
        }

        if (i == s.len - 1) wordEnded = true;

        // print("wordEnded: {}, word.items.len: {}\n", .{ wordEnded, word.items.len });
        if (wordEnded and word.items.len != 0) {
            // print("map.put: {s}\n", .{word.items});
            const dupe = try allocator.dupe(u8, word.items);
            // defer allocator.free(dupe);
            errdefer allocator.free(dupe);
            try map.put(dupe, if (map.get(dupe)) |count|
                count + 1
            else
                1);
            word.clearAndFree();
            wordEnded = false;
        }
    }
    var iter = map.iterator();
    while (iter.next()) |entry| {
        print("{s}: {}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    }

    return map;
}
