const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");

const win_width = 800;
const win_height = 450;

const Ball = @import("ball.zig").Ball;
const Paddle = @import("paddle.zig").Paddle;
const GameState = enum {
    playing,
    game_over,
};

pub fn main() anyerror!void {
    rl.initWindow(win_width, win_height, "Pong");
    defer rl.closeWindow();
    rl.setTargetFPS(60);
    set_styles();

    var state = GameState.playing;
    var ball = Ball.init(win_width, win_height);
    var paddle = Paddle.init(win_height);

    while (!rl.windowShouldClose()) {
        // Update
        update(&state, &ball, &paddle);
        // Draw
        rl.beginDrawing();
        defer rl.endDrawing();
        draw(state, ball, paddle);
    }
}

fn update(state: *GameState, ball: *Ball, paddle: *Paddle) void {
    switch (state.*) {
        .playing => {
            paddle.update(win_height);
            ball.update(win_width, win_height, paddle.*);
            // Check if ball is lost
            if (ball.pos.x + ball.size / 2 < 0) {
                state.* = GameState.game_over;
            }
        },
        .game_over => {
            const button_width = 120;
            const button_height = 40;
            const button_x = @divFloor(win_width - button_width, 2);
            const button_y = @divFloor(win_height - button_height, 2);
            // Check for button click or Enter key
            if (rg.guiButton(rl.Rectangle{
                .x = @floatFromInt(button_x),
                .y = @floatFromInt(button_y),
                .width = @floatFromInt(button_width),
                .height = @floatFromInt(button_height),
            }, "Restart") == 1 or rl.isKeyPressed(rl.KeyboardKey.enter)) {
                state.* = GameState.playing;
                ball.* = Ball.init(win_width, win_height);
                paddle.* = Paddle.init(win_height);
            }
        },
    }
}

fn draw(state: GameState, ball: Ball, paddle: Paddle) void {
    rl.clearBackground(rl.Color.black);
    switch (state) {
        .playing => {
            // Draw middle line
            const mid_start = rl.Vector2{ .x = win_width / 2, .y = 0 };
            const mid_end = rl.Vector2{ .x = win_width / 2, .y = 10 };
            draw_dashed_line(mid_start, mid_end, 1, rl.Color.white, rl.Vector2{ .x = win_width, .y = win_height }, 1);

            paddle.draw();
            ball.draw();
        },
        .game_over => {
            draw_game_over_text("Game Over", 40, rl.Color.white);
            paddle.draw();
            ball.draw();
        },
    }
}

fn draw_dashed_line(start: rl.Vector2, end: rl.Vector2, thick: f32, color: rl.Color, bound: rl.Vector2, space_factor: f32) void {
    const delta = rl.Vector2.subtract(end, start);
    // delta_length = √(delta.x² + delta.y²)
    const delta_len = rl.Vector2.length(delta);
    // normalize to get unit vector
    const direction = rl.Vector2{ .x = delta.x / delta_len, .y = delta.y / delta_len };

    // √((x₂ - x₁)² + (y₂ - y₁)²)
    const dash_length = rl.Vector2.distance(start, end);
    const space_length = dash_length * space_factor;

    var current = start;
    while (current.x < bound.x and current.y < bound.y) {
        const dash_end = rl.Vector2{ .x = current.x + direction.x * dash_length, .y = current.y + direction.y * dash_length };
        rl.drawLineEx(current, dash_end, thick, color);
        current = rl.Vector2{ .x = dash_end.x + direction.x * space_length, .y = dash_end.y + direction.y * space_length };
    }
}

fn draw_game_over_text(text: [*:0]const u8, font_size: i32, color: rl.Color) void {
    const text_width = rl.measureText(text, font_size);
    rl.drawText(
        text,
        @divFloor(win_width - text_width, 2),
        @divFloor(win_height - font_size, 2) - 50,
        font_size,
        color,
    );
}

fn set_styles() void {
    rg.guiSetStyle(rg.GuiControl.button, rg.GuiControlProperty.base_color_normal, rl.Color.black.toInt());
    rg.guiSetStyle(rg.GuiControl.button, rg.GuiControlProperty.text_color_normal, rl.Color.white.toInt());

    rg.guiSetStyle(rg.GuiControl.button, rg.GuiControlProperty.base_color_focused, rl.Color.dark_gray.toInt());
    rg.guiSetStyle(rg.GuiControl.button, rg.GuiControlProperty.text_color_focused, rl.Color.white.toInt());
    rg.guiSetStyle(rg.GuiControl.button, rg.GuiControlProperty.border_color_focused, rl.Color.white.toInt());
}
