const std = @import("std");
const Zig = @import("Zig");
const rl = @import("raylib");
const rlm = rl.math;

const SCREEN_SIZE = rl.Vector2.init(480, 480);
const ALIENS_X_COUNT = 11;
const ALIENS_Y_COUNT = 5;

const Player = struct {
    sprite: rl.Texture,
    pos: rl.Vector2,
};

const Alien = struct {
    sprite1: rl.Texture,
    sprite2: rl.Texture,
    pos: rl.Vector2,
};

const State = struct {
    time: f32,
    deltaTime: f32,
    aliensUpdateState: u8,
    aliensDirection: i8,
    player: Player,
    aliens: [ALIENS_X_COUNT * ALIENS_Y_COUNT]Alien,
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

    // Update aliens
    const previousUpdateState = state.aliensUpdateState;
    state.aliensUpdateState = @as(u8, @intFromFloat(state.time * 20)) % 2;
    if (previousUpdateState != state.aliensUpdateState) {
        for (&state.aliens) |*alien| {
            if (alien.pos.x <= 0 and state.aliensDirection == -1 or
                alien.pos.x >= SCREEN_SIZE.x - @as(f32, @floatFromInt(alien.sprite1.width)) and state.aliensDirection == 1)
            {
                state.aliensDirection = -state.aliensDirection;
                moveAliensDown();
                break;
            }
        }

        for (&state.aliens) |*alien| {
            alien.pos = rlm.vector2Add(
                alien.pos,
                rl.Vector2.init(
                    @as(f32, @floatFromInt(state.aliensDirection)) * 100 * state.deltaTime,
                    0,
                ),
            );
        }
    }
}

fn render() void {
    rl.drawTextureV(
        state.player.sprite,
        state.player.pos,
        .green,
    );
    for (state.aliens) |alien| {
        rl.drawTextureV(
            switch (@as(u32, @intFromFloat(state.time * 2)) % 2) {
                0 => alien.sprite1,
                else => alien.sprite2,
            },
            alien.pos,
            .white,
        );
    }

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
        .aliensDirection = 1,
        .aliensUpdateState = 0,
        .player = .{
            .sprite = playerTexture,
            .pos = .init(196, 400),
        },
        .aliens = undefined,
    };
    init_aliens() catch |err| return err;

    while (!rl.windowShouldClose()) {
        state.deltaTime = rl.getFrameTime();
        state.time += state.deltaTime;

        update();

        rl.beginDrawing();
        defer rl.endDrawing();

        render();
    }
}

fn init_aliens() !void {
    const alien1Texture1 = rl.loadTexture("resources/sprites/Invaders/space__0000_A1.png") catch |err| return err;
    const alien1Texture2 = rl.loadTexture("resources/sprites/Invaders/space__0001_A2.png") catch |err| return err;
    const alien2Texture1 = rl.loadTexture("resources/sprites/Invaders/space__0002_B1.png") catch |err| return err;
    const alien2Texture2 = rl.loadTexture("resources/sprites/Invaders/space__0003_B2.png") catch |err| return err;
    const alien3Texture1 = rl.loadTexture("resources/sprites/Invaders/space__0004_C1.png") catch |err| return err;
    const alien3Texture2 = rl.loadTexture("resources/sprites/Invaders/space__0005_C2.png") catch |err| return err;

    var index: usize = 0;
    for (0..ALIENS_Y_COUNT) |y| {
        for (0..ALIENS_X_COUNT) |x| {
            state.aliens[index] = Alien{
                .sprite1 = switch (y) {
                    0 => alien1Texture1,
                    1, 2 => alien2Texture1,
                    else => alien3Texture1,
                },
                .sprite2 = switch (y) {
                    0 => alien1Texture2,
                    1, 2 => alien2Texture2,
                    else => alien3Texture2,
                },
                .pos = rl.Vector2.init(
                    @as(f32, @floatFromInt(@as(c_int, @intCast(x)) * (alien1Texture1.width + 10) + 35)),
                    @as(f32, @floatFromInt(@as(c_int, @intCast(y)) * (alien1Texture1.height + 10) + 35)),
                ),
            };
            index += 1;
        }
    }
}

fn moveAliensDown() void {
    for (&state.aliens) |*alien| {
        alien.pos = rlm.vector2Add(
            alien.pos,
            rl.Vector2.init(0, 4),
        );
    }
}
