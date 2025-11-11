const std = @import("std");
const Zig = @import("Zig");
const rl = @import("raylib");
const rlm = rl.math;

const SCREEN_SIZE = rl.Vector2.init(480, 480);

const Player = struct {
    sprite: rl.Texture,
    pos: rl.Vector2,
};

const State = struct {
    time: f32,
    deltaTime: f32,
    player: Player,
};
var state: State = undefined;

fn update() void {
    const SPEED = 120;
    // Update
    if (rl.isKeyDown(.a) and state.player.pos.x > 0) {
        state.player.pos.x -= state.deltaTime * SPEED;
    }
    if (rl.isKeyDown(.d) and state.player.pos.x < SCREEN_SIZE.x - @as(f32, @floatFromInt(state.player.sprite.width))) {
        state.player.pos.x += state.deltaTime * SPEED;
    }
}

fn render() void {
    rl.drawTextureV(
        state.player.sprite,
        state.player.pos,
        .green,
    );

    rl.clearBackground(.black);
}

pub fn main() !void {
    rl.initWindow(SCREEN_SIZE.x, SCREEN_SIZE.y, "Otherworldly Interlopers");
    defer rl.closeWindow();
    rl.setTargetFPS(60);

    const playerTexture = rl.loadTexture("resources/sprites/Invaders/space__0006_Player.png") catch |err| return err;
    state = .{
        .time = 0,
        .deltaTime = rl.getFrameTime(),
        .player = .{
            .sprite = playerTexture,
            .pos = .init(196, 400),
        },
    };

    while (!rl.windowShouldClose()) {
        state.deltaTime = rl.getFrameTime();
        state.time += state.deltaTime;

        update();

        rl.beginDrawing();
        defer rl.endDrawing();

        render();
    }
}

test "simple test" {
    const gpa = std.testing.allocator;
    var list: std.ArrayList(i32) = .empty;
    defer list.deinit(gpa); // Try commenting this out and see if zig detects the memory leak!
    try list.append(gpa, 42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

test "fuzz example" {
    const Context = struct {
        fn testOne(context: @This(), input: []const u8) anyerror!void {
            _ = context;
            // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!
            try std.testing.expect(!std.mem.eql(u8, "canyoufindme", input));
        }
    };
    try std.testing.fuzz(Context{}, Context.testOne, .{});
}
