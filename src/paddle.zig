const rl = @import("raylib");

const Ball = @import("ball.zig").Ball;

pub const Paddle = struct {
    // left, top
    pos: rl.Vector2,
    size: rl.Vector2,
    speed: f32,

    pub fn init(win_height: f32) Paddle {
        return Paddle.new(50, win_height / 2 - 30);
    }

    pub fn new(x: f32, y: f32) Paddle {
        return Paddle{
            .pos = .{ .x = x, .y = y },
            .size = .{ .x = 10, .y = 60 },
            .speed = 5,
        };
    }

    pub fn update(self: *Paddle, win_height: f32) void {
        if (rl.isKeyDown(rl.KeyboardKey.w)) {
            self.pos.y -= self.speed;
        }
        if (rl.isKeyDown(rl.KeyboardKey.s)) {
            self.pos.y += self.speed;
        }
        // Keep paddle within screen bounds
        if (self.pos.y < 0) {
            self.pos.y = 0;
        }
        if (self.pos.y + self.size.y > win_height) {
            self.pos.y = win_height - self.size.y;
        }
    }

    pub fn draw(self: Paddle) void {
        rl.drawRectangle(
            @intFromFloat(self.pos.x),
            @intFromFloat(self.pos.y),
            @intFromFloat(self.size.x),
            @intFromFloat(self.size.y),
            rl.Color.white,
        );
    }

    pub fn checkCollision(self: Paddle, ball: *Ball) bool {
        // Paddle bounds
        const paddle_left = self.pos.x;
        const paddle_right = self.pos.x + self.size.x;
        const paddle_top = self.pos.y;
        const paddle_bottom = self.pos.y + self.size.y;
        // Ball bounds
        const ball_left = ball.pos.x - ball.size / 2;
        const ball_right = ball.pos.x + ball.size / 2;
        const ball_top = ball.pos.y - ball.size / 2;
        const ball_bottom = ball.pos.y + ball.size / 2;
        // AABB (Axis-Aligned Bounding Box)
        return ball_left <= paddle_right and
            ball_right >= paddle_left and
            ball_top <= paddle_bottom and
            ball_bottom >= paddle_top;
    }

    pub fn getDirection(_: Paddle) f32 {
        if (rl.isKeyDown(rl.KeyboardKey.w)) return -1;
        if (rl.isKeyDown(rl.KeyboardKey.s)) return 1;
        return 0;
    }
};
