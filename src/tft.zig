// SPDX-License-Identifier: MPL-2.0
// Copyright © 2024 The Tft Contributors. All rights reserved.
// Contributors responsible for this file:
// @p7r0x7 <mattrbonnette@pm.me>

const std = @import("std");
const io = @import("std").io;
const fmt = @import("std").fmt;
const Sfc = @import("std").rand.Sfc64;

const sextants = .{
    " ", //  U+0020 SPACE
    "█", //  U+2588 FULL BLOCK
    "▌", //  U+258C LEFT HALF BLOCK
    "▐", //  U+2590 RIGHT HALF BLOCK
    "🬀", // U+1FB00 BLOCK SEXTANT-1
    "🬁", // U+1FB01 BLOCK SEXTANT-2
    "🬂", // U+1FB02 BLOCK SEXTANT-12
    "🬃", // U+1FB03 BLOCK SEXTANT-3
    "🬄", // U+1FB04 BLOCK SEXTANT-13
    "🬅", // U+1FB05 BLOCK SEXTANT-23
    "🬆", // U+1FB06 BLOCK SEXTANT-123
    "🬇", // U+1FB07 BLOCK SEXTANT-4
    "🬈", // U+1FB08 BLOCK SEXTANT-14
    "🬉", // U+1FB09 BLOCK SEXTANT-24
    "🬊", // U+1FB0A BLOCK SEXTANT-124
    "🬋", // U+1FB0B BLOCK SEXTANT-34
    "🬌", // U+1FB0C BLOCK SEXTANT-134
    "🬍", // U+1FB0D BLOCK SEXTANT-234
    "🬎", // U+1FB0E BLOCK SEXTANT-1234
    "🬏", // U+1FB0F BLOCK SEXTANT-5
    "🬐", // U+1FB10 BLOCK SEXTANT-15
    "🬑", // U+1FB11 BLOCK SEXTANT-25
    "🬒", // U+1FB12 BLOCK SEXTANT-125
    "🬓", // U+1FB13 BLOCK SEXTANT-35
    "🬔", // U+1FB14 BLOCK SEXTANT-235
    "🬕", // U+1FB15 BLOCK SEXTANT-1235
    "🬖", // U+1FB16 BLOCK SEXTANT-45
    "🬗", // U+1FB17 BLOCK SEXTANT-145
    "🬘", // U+1FB18 BLOCK SEXTANT-245
    "🬙", // U+1FB19 BLOCK SEXTANT-1245
    "🬚", // U+1FB1A BLOCK SEXTANT-345
    "🬛", // U+1FB1B BLOCK SEXTANT-1345
    "🬜", // U+1FB1C BLOCK SEXTANT-2345
    "🬝", // U+1FB1D BLOCK SEXTANT-12345
    "🬞", // U+1FB1E BLOCK SEXTANT-6
    "🬟", // U+1FB1F BLOCK SEXTANT-16
    "🬠", // U+1FB20 BLOCK SEXTANT-26
    "🬡", // U+1FB21 BLOCK SEXTANT-126
    "🬢", // U+1FB22 BLOCK SEXTANT-36
    "🬣", // U+1FB23 BLOCK SEXTANT-136
    "🬤", // U+1FB24 BLOCK SEXTANT-236
    "🬥", // U+1FB25 BLOCK SEXTANT-1236
    "🬦", // U+1FB26 BLOCK SEXTANT-46
    "🬧", // U+1FB27 BLOCK SEXTANT-146
    "🬨", // U+1FB28 BLOCK SEXTANT-1246
    "🬩", // U+1FB29 BLOCK SEXTANT-346
    "🬪", // U+1FB2A BLOCK SEXTANT-1346
    "🬫", // U+1FB2B BLOCK SEXTANT-2346
    "🬬", // U+1FB2C BLOCK SEXTANT-12346
    "🬭", // U+1FB2D BLOCK SEXTANT-56
    "🬮", // U+1FB2E BLOCK SEXTANT-156
    "🬯", // U+1FB2F BLOCK SEXTANT-256
    "🬰", // U+1FB30 BLOCK SEXTANT-1256
    "🬱", // U+1FB31 BLOCK SEXTANT-356
    "🬲", // U+1FB32 BLOCK SEXTANT-1356
    "🬳", // U+1FB33 BLOCK SEXTANT-2356
    "🬴", // U+1FB34 BLOCK SEXTANT-12356
    "🬵", // U+1FB35 BLOCK SEXTANT-456
    "🬶", // U+1FB36 BLOCK SEXTANT-1456
    "🬷", // U+1FB37 BLOCK SEXTANT-2456
    "🬸", // U+1FB38 BLOCK SEXTANT-12456
    "🬹", // U+1FB39 BLOCK SEXTANT-3456
    "🬺", // U+1FB3A BLOCK SEXTANT-13456
    "🬻", // U+1FB3B BLOCK SEXTANT-23456
};

const palette = precomp: {
    @setEvalBranchQuota(1 << 32 - 1);
    var tab: [sextants.len * 16 * 15][]const u8 = undefined;
    var dex: usize = 0;

    for (sextants) |rune| {
        const seq = "\x1b[{d};{d}m{s}";
        for (30..38) |fg| {
            for (40..48) |bg| {
                if (fg == bg - 10) continue;
                tab[dex] = fmt.comptimePrint(seq, .{ fg, bg, rune });
                dex +%= 1;
            }
            for (100..108) |bg| {
                if (fg == bg - 10) continue;
                tab[dex] = fmt.comptimePrint(seq, .{ fg, bg, rune });
                dex +%= 1;
            }
        }
        for (90..98) |fg| {
            for (40..48) |bg| {
                if (fg == bg - 10) continue;
                tab[dex] = fmt.comptimePrint(seq, .{ fg, bg, rune });
                dex +%= 1;
            }
            for (100..108) |bg| {
                if (fg == bg - 10) continue;
                tab[dex] = fmt.comptimePrint(seq, .{ fg, bg, rune });
                dex +%= 1;
            }
        }
    }
    break :precomp tab;
};

const so = io.getStdOut().writer();
var buf = io.bufferedWriter(so);
var sfc = Sfc.init(0);
const prng = sfc.random();

pub fn main() void {
    while (true) _ = buf.write(palette[prng.uintLessThan(usize, palette.len)]) catch unreachable;
}

test "1M" {
    for (0..1 << 20) |_| _ = buf.write(palette[prng.uintLessThan(usize, palette.len)]) catch unreachable;
}
