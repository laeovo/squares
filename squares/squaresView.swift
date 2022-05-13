import ScreenSaver

let stepDuration: UInt8 = 10
let pauseDuration: UInt8 = 2
let spawnRelax = 1

let screenSize: CGRect = NSScreen.main!.frame
let screenWidth: UInt16 = UInt16(screenSize.width)
let screenHeight: UInt16 = UInt16(screenSize.height)
let boxesX: UInt16 = 32
let boxesY: UInt16 = (boxesX * screenHeight) / screenWidth
let totalNrBoxes: UInt16 = boxesX * boxesY
let squareSparcity: UInt16 = 1

let boxSize: CGFloat = CGFloat(screenWidth / boxesX)
let edgeRadius: CGFloat = 15
let fillColor = NSColor(red: 0, green: 0, blue: 0, alpha: 0.5)
let edgeWidth: CGFloat = 5

let hueVariation = 0.1
let hueSpeed = 0.001
let sat = 0.3
let minAge = 20
let maxAge = 30
let chanceOfDeath = 0.5

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
    }
    private func shrink() {
        color = NSColor(red: color.redComponent, green: color.greenComponent, blue: color.blueComponent, alpha: 1.0 - CGFloat(Float(progress) / Float(stepDuration)))
    }
    
    public func draw() {
        let shapeRect = NSRect(x: currentPosition.x, y: currentPosition.y, width: CGFloat(boxSize), height: CGFloat(boxSize))
        let shape = NSBezierPath(roundedRect: shapeRect, xRadius: edgeRadius, yRadius: edgeRadius)
        color.setFill()
        shape.fill()
        
        let fillRect = NSRect(x: currentPosition.x+edgeWidth, y: currentPosition.y+edgeWidth, width: CGFloat(boxSize-2*edgeWidth), height: CGFloat(boxSize-2*edgeWidth))
        fillColor.setFill()
        let fillShape = NSBezierPath(roundedRect: fillRect, xRadius: edgeRadius-edgeWidth, yRadius: edgeRadius-edgeWidth)
        fillShape.fill()
    }
    
    public func getCurrentCell() -> CGPoint {
        return currentCell
    }
    
    public func getTargetCell() -> CGPoint {
        return targetCell
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
    
    private var initTimer: UInt16 = 0
    private var squares: [square] = []
    private var currentHue: Double = Double.random(in: 0...1)

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
        for activeSquare in squares {
            activeSquare.draw()
        }
    }

    override func animateOneFrame() {
        super.animateOneFrame()
        
        if squares.count < totalNrBoxes/squareSparcity && Int(initTimer)%Int(spawnRelax) == 0 {
            createNewSquare()
        }
        initTimer += 1
        
        for activeSquare in squares {
            if activeSquare.getState() == "idle" {
                if (activeSquare.getAge() > minAge && Double.random(in: 0.0...1) < chanceOfDeath) || activeSquare.getAge() > maxAge {
                    activeSquare.initNextAction(newState: "shrink")
                }
                else {
                    var moveDirections: [String] = []
                    let activeSquareCurrentCell = activeSquare.getCurrentCell()
                    if activeSquareCurrentCell.x > 0 && activeSquare.getLastDirection() != "right" && cellIsEmpty(cell: CGPoint(x: activeSquareCurrentCell.x-1, y: activeSquareCurrentCell.y)) {
                        moveDirections.append("moveLeft")
                    }
                    if activeSquareCurrentCell.x < CGFloat(boxesX - 1) && activeSquare.getLastDirection() != "left" && cellIsEmpty(cell: CGPoint(x: activeSquareCurrentCell.x+1, y: activeSquareCurrentCell.y)) {
                        moveDirections.append("moveRight")
                    }
                    if activeSquareCurrentCell.y > 0 && activeSquare.getLastDirection() != "up" && cellIsEmpty(cell: CGPoint(x: activeSquareCurrentCell.x, y: activeSquareCurrentCell.y-1)) {
                        moveDirections.append("moveDown")
                    }
                    if activeSquareCurrentCell.y < CGFloat(boxesY - 1) && activeSquare.getLastDirection() != "down" && cellIsEmpty(cell: CGPoint(x: activeSquareCurrentCell.x, y: activeSquareCurrentCell.y+1)) {
                        moveDirections.append("moveUp")
                    }
                    if moveDirections.isEmpty {
                        activeSquare.initNextAction(newState: "shrink")
                    }
                    else {
                        let moveDirection = moveDirections.randomElement()!
                        activeSquare.initNextAction(newState: moveDirection)
                    }
                }
            }
            else {
                activeSquare.makeProgress()
            }
        }
        
        // remove dead squares
        var removedSquares = 0
        for i in 0...squares.count-1 {
            let index = i - removedSquares
            if squares[index].getState() == "inactive" {
                squares.remove(at: index)
                removedSquares += 1
            }
        }

        currentHue += hueSpeed
        setNeedsDisplay(bounds)
    }

    private func drawBackground(_ color: NSColor) {
        let background = NSBezierPath(rect: bounds)
        color.setFill()
        background.fill()
    }
    
    private func createNewSquare() {
        let newSquare = square()
        var cellCandidate: CGPoint
        var tries = 0
        repeat {
            cellCandidate = CGPoint(x: Int.random(in: 0..<Int(boxesX)), y: Int.random(in: 0..<Int(boxesY)))
            tries += 1
        }
        while !cellIsEmpty(cell: cellCandidate) && tries < squares.count
        if cellIsEmpty(cell: cellCandidate) {
            newSquare.activate(position: cellCandidate, newColor: NSColor(hue: Double.random(in: currentHue-hueVariation...currentHue-hueVariation).truncatingRemainder(dividingBy: 1), saturation: sat, brightness: 1.0, alpha: 0.0))
            squares.append(newSquare)
        }
    }
    
    private func cellIsEmpty(cell: CGPoint) -> Bool {
        for activeSquare in squares {
            if cell == activeSquare.getCurrentCell() {
                return false
            }
            if cell == activeSquare.getTargetCell() {
                return false
            }
        }
        return true
    }
}