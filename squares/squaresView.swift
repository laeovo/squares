import ScreenSaver

let stepDuration: UInt8 = 10
let pauseDuration: UInt8 = 10
let spawnRelax = 40

let screenSize: CGRect = NSScreen.main!.frame
let screenWidth: UInt16 = UInt16(screenSize.width)
let screenHeight: UInt16 = UInt16(screenSize.height)
let boxesX: UInt16 = 32
let boxesY: UInt16 = (boxesX * screenHeight) / screenWidth
let boxSize: CGFloat = CGFloat(screenWidth / boxesX)

class square {
    init() {
        currentCell = CGPoint(x: 0, y: 0)
        targetCell = currentCell
        currentPosition = CGPoint(x: CGFloat(boxSize)*currentCell.x, y: CGFloat(boxSize)*currentCell.y)
        age = 0
        state = "inactive"
    }
    
    private var state: String
    private var progress: UInt8 = 0
    private var currentCell: CGPoint
    private var targetCell: CGPoint
    private var currentPosition: CGPoint
    private var color: NSColor = NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
    private var age: UInt8
    private var lastDirection = "none"
    
    public func activate(position: CGPoint, newColor: NSColor) {
        currentCell = position
        targetCell = position
        currentPosition = CGPoint(x: CGFloat(boxSize)*currentCell.x, y: CGFloat(boxSize)*currentCell.y)
        initNextAction(newState: "grow")
        color = newColor
    }
    
    public func initNextAction(newState: String) {
        if newState == "moveUp" {
            state = "move"
            targetCell.x = currentCell.x
            targetCell.y = currentCell.y+1
            lastDirection = "up"
        }
        else if newState == "moveRight" {
            state = "move"
            targetCell.x = currentCell.x+1
            targetCell.y = currentCell.y
            lastDirection = "right"
        }
        else if newState == "moveDown" {
            state = "move"
            targetCell.x = currentCell.x
            targetCell.y = currentCell.y-1
            lastDirection = "down"
        }
        else if newState == "moveLeft" {
            state = "move"
            targetCell.x = currentCell.x-1
            targetCell.y = currentCell.y
            lastDirection = "left"
        }
        else {
            state = newState
        }
        progress = 0
    }
    
    public func makeProgress() {
        progress += 1
        if state == "grow" {
            grow()
            if progress == stepDuration {
                state = "idle"
                age = 0
            }
        }
        else if state == "move" {
//            let phase = 0.5 - 0.5 + cos(Double.pi * Double(progress) / Double(stepDuration)) // New code, but doesn't work
//            currentPosition.x = CGFloat(boxSize) * CGFloat((targetCell.x-currentCell.x) * phase + currentCell.x)
//            currentPosition.y = CGFloat(boxSize) * CGFloat((targetCell.y-currentCell.y) * phase + currentCell.y)
            
            currentPosition.x = boxSize*currentCell.x + boxSize*(targetCell.x-currentCell.x)*(0.5-0.5*cos(CGFloat(Double.pi)*CGFloat(progress)/CGFloat(stepDuration)))
            currentPosition.y = boxSize*currentCell.y + boxSize*(targetCell.y-currentCell.y)*(0.5-0.5*cos(CGFloat(Double.pi)*CGFloat(progress)/CGFloat(stepDuration)))
            
            if progress == stepDuration {
                currentCell = targetCell
                state = "idle"
                age += 1
            }
        }
        else if state == "shrink" {
            shrink()
            if progress == stepDuration {
                currentCell = targetCell
                state = "inactive"
                age += 1
            }
        }
    }
    
    public func getState() -> String {
        return state
    }
    
    public func getAge() -> UInt8 {
        return age
    }
    
    private func grow() {
        color = NSColor(red: color.redComponent, green: color.greenComponent, blue: color.blueComponent, alpha: CGFloat(Float(progress) / Float(stepDuration)))
//        color = NSColor(red: 1, green: 0, blue: 0, alpha: 1)
    }
    private func shrink() {
        color = NSColor(red: color.redComponent, green: color.greenComponent, blue: color.blueComponent, alpha: 1.0 - CGFloat(Float(progress) / Float(stepDuration)))
    }
    
    public func draw() {
        let shapeRect = NSRect(x: currentPosition.x, y: currentPosition.y, width: CGFloat(boxSize), height: CGFloat(boxSize))
        let shape = NSBezierPath(roundedRect: shapeRect, xRadius: 15, yRadius: 15)
        color.setFill()
        shape.fill()
    }
    
    public func getCurrentCell() -> CGPoint {
        return currentCell
    }
    
    public func getLastDirection() -> String {
        return lastDirection
    }
}

class squaresView: ScreenSaverView {

    private var ballPosition: CGPoint = .zero
    private var ballVelocity: CGVector = .zero
    private var paddlePosition: CGFloat = 0
    private let ballRadius: CGFloat = 15
    private let paddleBottomOffset: CGFloat = 100
    private let paddleSize = NSSize(width: 60, height: 20)
    
    private var testSquare: square = square() // TODO: construct squares on the run

    // MARK: - Initialization
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
    }

    @available(*, unavailable)
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func draw(_ rect: NSRect) {
        drawBackground(.black)
        testSquare.draw()
        
//        drawBall()
//        drawPaddle()
    }

    override func animateOneFrame() {
        super.animateOneFrame()
        
        if testSquare.getState() == "inactive" {
            testSquare.activate(position: CGPoint(x: Int.random(in: 0..<Int(boxesX)), y: Int.random(in: 0..<Int(boxesY))), newColor: NSColor(red: Double.random(in: 0.25...1.0), green: Double.random(in: 0.25...1.0), blue: Double.random(in: 0.25...1.0), alpha: 0.0))
        }
        else if testSquare.getState() == "idle" {
            if testSquare.getAge() == 100 {
                testSquare.initNextAction(newState: "shrink")
            }
            else {
                var moveDirections: [String] = []
                let testSquareCurrentCell = testSquare.getCurrentCell()
                if testSquareCurrentCell.x > 0 && testSquare.getLastDirection() != "right" {
                    moveDirections.append("moveLeft")
                }
                if testSquareCurrentCell.x < CGFloat(boxesX - 1) && testSquare.getLastDirection() != "left" {
                    moveDirections.append("moveRight")
                }
                if testSquareCurrentCell.y > 0 && testSquare.getLastDirection() != "up" {
                    moveDirections.append("moveDown")
                }
                if testSquareCurrentCell.y < CGFloat(boxesY - 1) && testSquare.getLastDirection() != "down" {
                    moveDirections.append("moveUp")
                }
                let moveDirection = moveDirections.randomElement()!
                testSquare.initNextAction(newState: moveDirection)
            }
        }
        else {
            testSquare.makeProgress()
        }

//        let oobAxes = ballIsOOB()
//        if oobAxes.xAxis {
//            ballVelocity.dx *= -1
//        }
//        if oobAxes.yAxis {
//            ballVelocity.dy *= -1
//        }
//
//        let paddleContact = ballHitPaddle()
//        if paddleContact {
//            ballVelocity.dy *= -1
//        }
//
//        ballPosition.x += ballVelocity.dx
//        ballPosition.y += ballVelocity.dy
//        paddlePosition = ballPosition.x

        setNeedsDisplay(bounds)
    }

    // MARK: - Helper Functions
    private func drawBackground(_ color: NSColor) {
        let background = NSBezierPath(rect: bounds)
        color.setFill()
        background.fill()
    }

    private func drawBall() {
        let ballRect = NSRect(x: ballPosition.x - ballRadius,
                              y: ballPosition.y - ballRadius,
                              width: ballRadius * 2,
                              height: ballRadius * 2)
        let ball = NSBezierPath(roundedRect: ballRect,
                                xRadius: ballRadius,
                                yRadius: ballRadius)
        NSColor.white.setFill()
        ball.fill()
    }

    private func drawPaddle() {
        let paddleRect = NSRect(x: paddlePosition - paddleSize.width / 2,
                                y: paddleBottomOffset - paddleSize.height / 2,
                                width: paddleSize.width,
                                height: paddleSize.height)
        let paddle = NSBezierPath(rect: paddleRect)
        NSColor.white.setFill()
        paddle.fill()
    }

    private func initialVelocity() -> CGVector {
        let desiredVelocityMagnitude: CGFloat = 10
        let xVelocity = CGFloat.random(in: 2.5...7.5)
        let xSign: CGFloat = Bool.random() ? 1 : -1
        let yVelocity = sqrt(pow(desiredVelocityMagnitude, 2) - pow(xVelocity, 2))
        let ySign: CGFloat = Bool.random() ? 1 : -1
        return CGVector(dx: xVelocity * xSign, dy: yVelocity * ySign)
    }

    private func ballIsOOB() -> (xAxis: Bool, yAxis: Bool) {
        let xAxisOOB = ballPosition.x - ballRadius <= 0 ||
            ballPosition.x + ballRadius >= bounds.width
        let yAxisOOB = ballPosition.y - ballRadius <= 0 ||
            ballPosition.y + ballRadius >= bounds.height
        return (xAxisOOB, yAxisOOB)
    }

    private func ballHitPaddle() -> Bool {
        let xBounds = (lower: paddlePosition - paddleSize.width / 2,
                       upper: paddlePosition + paddleSize.width / 2)
        let yBounds = (lower: paddleBottomOffset - paddleSize.height / 2,
                       upper: paddleBottomOffset + paddleSize.height / 2)
        return ballPosition.x >= xBounds.lower &&
            ballPosition.x <= xBounds.upper &&
            ballPosition.y - ballRadius >= yBounds.lower &&
            ballPosition.y - ballRadius <= yBounds.upper
    }
}
