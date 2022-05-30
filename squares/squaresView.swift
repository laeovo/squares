import ScreenSaver

class Particle {
    private var speed: CGVector = .zero
    private var position: CGPoint = .zero
    private var color: NSColor
    private var alive: Bool
    
    init(newColor: NSColor, newPosition: CGPoint, newSpeed: CGVector) {
        color = newColor
        position = newPosition
        speed = newSpeed
        alive = true
    }
    
    public func makeProgress() {
        color = NSColor(red: color.redComponent, green: color.greenComponent, blue: color.blueComponent, alpha: color.alphaComponent-particleDecay)
        position.x += speed.dx
        position.y += speed.dy
        if color.alphaComponent < 0.01 {
            color = NSColor(red: color.redComponent, green: color.greenComponent, blue: color.blueComponent, alpha: 0)
            alive = false
        }
        speed.dx -= particleDrift.dx
        speed.dx /= CGFloat.random(in: 1...particleSpeedDecay)
        speed.dx += particleDrift.dx
        speed.dy -= particleDrift.dy
        speed.dy /= CGFloat.random(in: 1...particleSpeedDecay)
        speed.dy += particleDrift.dy
    }
    
    public func draw() {
        let rect = NSRect(x: position.x, y: position.y, width: particleSize/2, height: particleSize/2)
        color.setFill()
        let shape = NSBezierPath(roundedRect: rect, xRadius: particleSize/2, yRadius: particleSize/2)
        shape.fill()
    }
    
    public func isAlive() -> Bool {
        return alive
    }
}

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
    private var history: [CGPoint] = []
    private var particles: [Particle] = []
    
    public func activate(position: CGPoint, newColor: NSColor) {
        currentCell = position
        targetCell = position
        currentPosition = CGPoint(x: CGFloat(boxSize)*currentCell.x, y: CGFloat(boxSize)*currentCell.y)
        initNextAction(newState: "grow")
        color = newColor
        history.append(position)
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
        if state == "move" {
            history.append(targetCell)
            if history.count > 2+trailLength {
                history.remove(at: 0)
            }
        }
        progress = 0
    }
    
    public func makeProgress() {
        // remove dead particles
        var removedParticles = 0
        if !particles.isEmpty {
            for i in 0...particles.count-1 {
                let index = i - removedParticles
                if !particles[index].isAlive() {
                    particles.remove(at: index)
                    removedParticles += 1
                }
            }
        }
        
        progress += 1
        for particle in particles {
            particle.makeProgress()
        }
        
        if state == "grow" {
            grow()
            if progress == stepDuration {
                state = "idle"
                age = 0
            }
        }
        else if state == "move" {
            let phase = Double(progress) / Double(stepDuration)
            // movedPhase: [0, 1] --> [0, 1]
//            let movedPhase = phase // linear
            let movedPhase = 0.5 - 0.5 * cos(Double.pi * phase) // cosine-ish
//            let movedPhase = 0.5 - 0.5 * cos(Double.pi * phase) // accelerated cosine
            currentPosition.x = boxSize * CGFloat((targetCell.x-currentCell.x) * movedPhase + currentCell.x)
            currentPosition.y = boxSize * CGFloat((targetCell.y-currentCell.y) * movedPhase + currentCell.y)
            if particlesActivated {
                particles.append(Particle(newColor: color, newPosition: CGPoint(x: currentPosition.x+CGFloat.random(in: boxSize/4...3*boxSize/4), y: currentPosition.y+CGFloat.random(in: boxSize/4...3*boxSize/4)), newSpeed: CGVector(dx: particleSpeed * (targetCell.x-currentCell.x+CGFloat.random(in: -particleSpeedVariation...particleSpeedVariation)), dy: particleSpeed * (targetCell.y-currentCell.y+CGFloat.random(in: -particleSpeedVariation...particleSpeedVariation)))))
            }
            
            if progress == stepDuration {
                currentCell = targetCell
                state = "idle"
                age += 1
            }
        }
        else if state == "shrink" {
            shrink()
            if (particlesActivated && progress == UInt8(1.0/particleDecay)) || (!particlesActivated && progress == stepDuration) {
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
        for particle in particles {
            particle.draw()
        }
        
        let shapeRect = NSRect(x: currentPosition.x, y: currentPosition.y, width: CGFloat(boxSize), height: CGFloat(boxSize))
        let shape = NSBezierPath(roundedRect: shapeRect, xRadius: cornerRadius, yRadius: cornerRadius)
        color.setFill()
        shape.fill()
        
        if boxFillActivated {
            let fillRect = NSRect(x: currentPosition.x+edgeWidth, y: currentPosition.y+edgeWidth, width: CGFloat(boxSize-2*edgeWidth), height: CGFloat(boxSize-2*edgeWidth))
            fillColor.setFill()
            let fillShape = NSBezierPath(roundedRect: fillRect, xRadius: cornerRadius-edgeWidth, yRadius: cornerRadius-edgeWidth)
            fillShape.fill()
        }
    }
    
    public func getOccupiedCells() -> [CGPoint] {
        return history
    }
    
    public func getCurrentCell() -> CGPoint {
        return currentCell
    }
    
    public func getLastDirection() -> String {
        return lastDirection
    }
}

class squaresView: ScreenSaverView {
    
    private var initTimer: UInt64 = 0
    private var squares: [square] = []

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
            for _ in 1...spawnAtOnce {
                createNewSquare()
            }
        }
        initTimer += 1
        
        for activeSquare in squares {
            if activeSquare.getState() == "idle" {
                if (activeSquare.getAge() > minAge && Double.random(in: 0.0...1) < chanceOfDeath) || activeSquare.getAge() >= maxAge {
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
            var hue: Double = Double.random(in: currentHue-hueVariation...currentHue+hueVariation)
            while hue > 1 {
                hue -= 1
            }
            while hue < 0 {
                hue += 1
            }
            newSquare.activate(position: cellCandidate, newColor: NSColor(hue: hue, saturation: Double.random(in: max(sat-satVariation, 0)...min(sat+satVariation, 1)), brightness: Double.random(in: max(brt-brtVariation, 0)...min(brt+brtVariation, 1)), alpha: 0.0))
            squares.append(newSquare)
        }
    }
    
    private func cellIsEmpty(cell: CGPoint) -> Bool {
        for activeSquare in squares {
            for occupiedCell in activeSquare.getOccupiedCells() {
                if cell == occupiedCell {
                    return false
                }
            }
        }
        return true
    }
}
