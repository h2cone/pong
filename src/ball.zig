const std = @import("std");
const rl = @import("raylib");

const Paddle = @import("paddle.zig").Paddle;

pub const Ball = struct {
    // center
    pos: rl.Vector2,
    vel: rl.Vector2,
    size: f32,

    // Initial speed range
    const init_speed_x_range = .{ .min = 4.0, .max = 5.0 };
    const init_speed_y_range = .{ .min = 2.5, .max = 3.5 };

    // Speed increase
    const speed_increase_x: f32 = 1.25;
    const speed_increase_y: f32 = 1.15;

    // Maximum speeds
    const max_speed_x: f32 = 9.0;
    const max_speed_y: f32 = 6.0;

    // Paddle influence
    const paddle_influence: f32 = 0.5;

    pub fn init(win_width: f32, win_height: f32) Ball {
        return Ball.new(win_width, win_height, 10);
    }

    pub fn new(win_width: f32, win_height: f32, size: f32) Ball {
        const rand = std.crypto.random;

        // Generate initial velocity
        // [0, 1) * (max - min) = [0, max - min)
        // [0, max - min) + min = [min, max)
        const init_speed_x = rand.float(f32) * (init_speed_x_range.max - init_speed_x_range.min) + init_speed_x_range.min;
        const init_speed_y = rand.float(f32) * (init_speed_y_range.max - init_speed_y_range.min) + init_speed_y_range.min;

        const vel_x = init_speed_x * if (rand.boolean()) @as(f32, 1) else @as(f32, -1);
        const vel_y = init_speed_y * if (rand.boolean()) @as(f32, 1) else @as(f32, -1);

        return Ball{
            .pos = .{ .x = win_width / 2, .y = win_height / 2 },
            .vel = .{ .x = vel_x, .y = vel_y },
            .size = size,
        };
    }

    pub fn update(self: *Ball, win_width: f32, win_height: f32, paddle: Paddle) void {
        // Update position
        self.pos.x += self.vel.x;
        self.pos.y += self.vel.y;

        // Bounce off walls (except left wall, as paddle is there)
        if (self.pos.x >= win_width) {
            self.vel.x *= -1;
        }
        if (self.pos.y <= 0 or self.pos.y >= win_height) {
            self.vel.y *= -1;
        }

        // Check collision with paddle
        if (paddle.checkCollision(self)) {
            // Calculate new velocities with different increase ratios
            const new_speed_x = @min(@abs(self.vel.x) * speed_increase_x, max_speed_x);
            const new_speed_y = @min(@abs(self.vel.y) * speed_increase_y, max_speed_y);

            // Get paddle movement direction {-1, 0, 1}
            const paddle_direction = paddle.getDirection();
            const vertical_adjustment = new_speed_y * paddle_influence * paddle_direction;

            // Reverse x direction and apply speed increase
            self.vel.x = -std.math.sign(self.vel.x) * new_speed_x;
            // Adjust y velocity based on paddle movement
            self.vel.y = std.math.sign(self.vel.y) * new_speed_y + vertical_adjustment;

            // Ensure ball doesn't get stuck inside paddle
            self.pos.x = paddle.pos.x + paddle.size.x + self.size / 2;
        }
    }

    pub fn draw(self: Ball) void {
        rl.drawRectangle(
            @intFromFloat(self.pos.x - self.size / 2),
            @intFromFloat(self.pos.y - self.size / 2),
            @intFromFloat(self.size),
            @intFromFloat(self.size),
            rl.Color.white,
        );
    }
};
