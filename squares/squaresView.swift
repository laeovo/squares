import ScreenSaver

let stepDuration: UInt8 = 100

class square {
    init() {
        
    }
    
    private var state: String = "inactive"
    private var progress: UInt8 = 0
    private var currentCell: CGPoint = CGPoint(x: 0, y: 0)
    private var color: NSColor = NSColor(red: 0.5, green: 0.75, blue: 0.0, alpha: 0.0)
    
    public func create(_ position: CGPoint) {
        currentCell = position
        state = "growing"
    }
    
    public func initNextAction(typeOfAction: String) {
        state = typeOfAction
    }
    
    public func makeProgress() {
        progress += 1
        if state == "moving" {
            //... move
        }
        if state == "growing" {
            grow()
        }
        if state == "dying" {
            shrink()
        }
        
        if progress == stepDuration {
            state = "idle"
        }
    }
    
    public func getState() -> String {
        return state
    }
    
    private func grow() {
        color = NSColor(red: color.redComponent, green: color.greenComponent, blue: color.blueComponent, alpha: CGFloat(Float(progress) / Float(stepDuration)))
    }
    private func shrink() {
        color = NSColor(red: color.redComponent, green: color.greenComponent, blue: color.blueComponent, alpha: 1.0 - CGFloat(Float(progress) / Float(stepDuration)))
    }
    
    public func draw() {
        let shapeRect = NSRect(x: 500, y: 500, width: 160, height: 160) // TODO: real values
        let shape = NSBezierPath(rect: shapeRect)
        color.setFill()
        shape.fill()
    }
}

class squaresView: ScreenSaverView {

    private var ballPosition: CGPoint = .zero
    private var ballVelocity: CGVector = .zero
    private var paddlePosition: CGFloat = 0
    private let ballRadius: CGFloat = 15
    private let paddleBottomOffset: CGFloat = 100
    private let paddleSize = NSSize(width: 60, height: 20)
    
    private let boxSizeApprox: UInt16 = 160
    private var boxSize: UInt16 = 0
    private let nrSquares = 10
    
    private var testSquare: square = square()

    // MARK: - Initialization
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        setBoxSize()
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
        
        if testSquare.getState() == "idle" {
            testSquare.create(CGPoint(x: 0, y: 0))
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
    
    private func setBoxSize() {
        boxSize = UInt16(frame.width / 16)
        
    }

}
