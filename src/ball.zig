const std = @import("std");
const rl = @import("raylib");

const Paddle = @import("paddle.zig").Paddle;

pub const Ball = struct {
    // center
    pos: rl.Vector2,
    vel: rl.Vector2,
    size: f32,

    // Initial speed range
    const init_speed_x_range = .{ .min = 3.0, .max = 4.0 };
    const init_speed_y_range = .{ .min = 2.0, .max = 3.0 };
    // Speed increase and limits
    const speed_increase: f32 = 1.15;
    const max_speed_x: f32 = 7.0;
    const max_speed_y: f32 = 5.0;
    // Add paddle influence to vertical velocity
    const paddle_influence: f32 = 0.4;

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
            // Calculate new velocity with speed increase
            const current_speed = rl.Vector2.length(self.vel);
            const new_speed = @min(current_speed * speed_increase, max_speed_x);
            const speed_ratio = new_speed / current_speed;

            // Get paddle movement direction {-1, 0, 1}
            const paddle_direction = paddle.getDirection();
            const vertical_adjustment = new_speed * paddle_influence * paddle_direction;

            // Reverse x direction and apply speed increase
            self.vel.x *= -speed_ratio;
            // Adjust y velocity based on paddle movement
            self.vel.y = self.vel.y * speed_ratio + vertical_adjustment;

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
