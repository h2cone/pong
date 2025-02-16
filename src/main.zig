const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");

const Ball = @import("ball.zig").Ball;
const Paddle = @import("paddle.zig").Paddle;

const GameState = enum {
    playing,
    game_over,
};

pub fn main() anyerror!void {
    const win_width = 800;
    const win_height = 450;

    rl.initWindow(win_width, win_height, "Pong");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    var state = GameState.playing;
    var ball = Ball.init(win_width, win_height);
    var paddle = Paddle.init(win_height);

    while (!rl.windowShouldClose()) {
        // Update
        switch (state) {
            .playing => {
                paddle.update(win_height);
                ball.update(win_width, win_height, paddle);

                // Check if ball is lost (passed left boundary)
                if (ball.pos.x + ball.size / 2 < 0) {
                    state = GameState.game_over;
                }
            },
            .game_over => {
                // Draw restart button in the center of the screen
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
                    // Reset game
                    state = GameState.playing;
                    ball = Ball.init(win_width, win_height);
                    paddle = Paddle.init(win_height);
                }
            },
        }

        // Draw
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.black);

        const mid_start = rl.Vector2{ .x = win_width / 2, .y = 0 };
        const mid_end = rl.Vector2{ .x = win_width / 2, .y = 10 };
        draw_dashed_line(mid_start, mid_end, 1, rl.Color.white, rl.Vector2{ .x = win_width, .y = win_height }, 1);

        paddle.draw();
        ball.draw();

        // Draw game over text
        if (state == GameState.game_over) {
            const text = "Game Over";
            const font_size = 40;
            const text_width = rl.measureText(text, font_size);
            rl.drawText(
                text,
                @divFloor(win_width - text_width, 2),
                @divFloor(win_height - font_size, 2) - 50,
                font_size,
                rl.Color.white,
            );
        }
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
