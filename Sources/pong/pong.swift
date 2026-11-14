// pong clone

import CRaylib

let COLOR_WHITE = Color(r: 255, g: 255, b: 255, a: 255)

struct Window {
    static let width: Int32 = 1000
    static let height: Int32 = 600
    static let fps: Int32 = 90
}

struct Game {
    var leftScore: Int = 0
    var rightScore: Int = 0

    mutating func reset() {
        leftScore = 0
        rightScore = 0
    }
    mutating func score(player: Alignment) {
        switch player {
        case .left:
            leftScore += 1
        case .right:
            rightScore += 1
        }
    }
    func drawScores() {
        DrawText("\(leftScore)", 100, 64, 64, COLOR_WHITE)
        DrawText("\(rightScore)", Window.width - 100, 64, 64, COLOR_WHITE)
    }
}

struct Ball {
    let size: Float = 10.0
    let speed: Float = 500.0
    let color: Color = Color(r: 255, g: 0, b: 0, a: 255)
    var pos: Vector2 = Vector2(x: 100, y: 100)
    var direction: (x: Float, y: Float) = (x: 1, y: 1)
    init() {
        center()
    }
    mutating func center() {
        self.pos.x = Float(Window.width) / 2
        self.pos.y = Float(Window.height) / 2
    }
    mutating func stop() {
        self.direction.x = 0
        self.direction.y = 0
    }
    mutating func start() {
        center()
        self.direction.x = Bool.random() ? 1 : -1
        self.direction.y = Bool.random() ? 1 : -1
    }
}
enum Alignment {
    case left
    case right
}
enum Movement {
    case up
    case down
}
struct Paddle {
    let size = Vector2(x: 10, y: 100)
    let color = COLOR_WHITE
    let alignment: Alignment
    let speed: Float = 500.0
    var pos: Vector2 = Vector2(x: 0, y: 0)

    init(alignment: Alignment) {
        self.alignment = alignment
        switch alignment {
        case .left:
            break
        case .right:
            self.pos.x = Float(Window.width) - self.size.x
        }

        pos.y = Float(Window.height) / 2 - self.size.y / 2

    }
    mutating func move(movement: Movement, dt: Float) {
        switch movement {
        case .up:
            self.pos.y -= self.pos.y >= 0 ? self.speed * dt : 0
        case .down:
            self.pos.y += self.pos.y <= Float(Window.height) - self.size.y ? self.speed * dt : 0
        }
    }
}
@main
struct swift_executable {

    static func main() {

        InitWindow(Window.width, Window.height, "Hello")
        InitAudioDevice()

        @MainActor
        struct Sounds {
            static let wall = LoadSound("assets/wall.wav")
            static let paddle = LoadSound("assets/paddle.wav")
            static let score = LoadSound("assets/score.wav")
        }

        SetTargetFPS(Window.fps)
        var ball = Ball()
        var game = Game()
        var leftPaddle = Paddle(alignment: .left)
        var rightPaddle = Paddle(alignment: .right)

        while !WindowShouldClose() {
            let dt = GetFrameTime()

            if IsKeyDown(KEY_W.rawValue) {
                leftPaddle.move(movement: .up, dt: dt)
            } else if IsKeyDown(KEY_S.rawValue) {
                leftPaddle.move(movement: .down, dt: dt)
            }

            if IsKeyDown(KEY_UP.rawValue) {
                rightPaddle.move(movement: .up, dt: dt)
            } else if IsKeyDown(KEY_DOWN.rawValue) {
                rightPaddle.move(movement: .down, dt: dt)
            }

            // wall collision
            if ball.pos.y + ball.size >= Float(Window.height) || ball.pos.y - ball.size <= 0 {
                ball.direction.y *= -1
                PlaySound(Sounds.wall)
            }

            // paddle collision
            if CheckCollisionCircleRec(
                ball.pos, ball.size,
                Rectangle(
                    x: leftPaddle.pos.x, y: leftPaddle.pos.y, width: leftPaddle.size.x,
                    height: leftPaddle.size.y))
            {
                ball.direction.x *= -1
                ball.pos.x = leftPaddle.pos.x + leftPaddle.size.x + ball.size
                PlaySound(Sounds.paddle)
            } else if CheckCollisionCircleRec(
                ball.pos, ball.size,
                Rectangle(
                    x: rightPaddle.pos.x, y: rightPaddle.pos.y, width: rightPaddle.size.x,
                    height: rightPaddle.size.y))
            {
                ball.direction.x *= -1
                ball.pos.x = rightPaddle.pos.x - ball.size
                PlaySound(Sounds.paddle)
            }

            if ball.pos.x > Float(Window.width) {
                PlaySound(Sounds.score)
                game.score(player: .left)
                ball.start()
            } else if ball.pos.x < 0 {
                PlaySound(Sounds.score)
                game.score(player: .right)
                ball.start()

            }

            ball.pos.x += ball.speed * ball.direction.x * dt
            ball.pos.y += ball.speed * ball.direction.y * dt

            BeginDrawing()
            ClearBackground(Color(r: 31, g: 31, b: 31, a: 255))

            DrawRectangleV(leftPaddle.pos, leftPaddle.size, leftPaddle.color)
            DrawRectangleV(rightPaddle.pos, rightPaddle.size, rightPaddle.color)
            DrawCircleV(ball.pos, ball.size, ball.color)
            game.drawScores()
            EndDrawing()
        }
        CloseAudioDevice()
        CloseWindow()
    }
}
