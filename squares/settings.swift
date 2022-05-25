import ScreenSaver

let stepDuration: UInt8 = 15
let spawnRelax = 1
let spawnAtOnce = 1

let particlesActivated: Bool = false
let trailLength: UInt8 = 0
let particleSize: CGFloat = 6
let particleDecay: Double = 0.01
let particleSpeed: CGFloat = 1
let particleSpeedVariation: Double = 1
let particleSpeedDecay: CGFloat = 1.2
let particleDrift: CGVector = CGVector(dx: 0, dy: 0)

let screenSize: CGRect = NSScreen.main!.frame
let screenWidth: UInt16 = UInt16(screenSize.width)
let screenHeight: UInt16 = UInt16(screenSize.height)
let boxesX: UInt16 = 64
let boxesY: UInt16 = UInt16((UInt32(boxesX) * UInt32(screenHeight)) / UInt32(screenWidth))
let totalNrBoxes: UInt16 = boxesX * boxesY
let squareSparcity: UInt16 = 5

let boxFillActivated: Bool = true;
let boxSize: CGFloat = CGFloat(screenWidth / boxesX)
let fillColor = NSColor(red: 0, green: 0, blue: 0, alpha: 0.5)
let cornerRadiusProportion: CGFloat = 0.25
let cornerRadius: CGFloat = boxSize * cornerRadiusProportion
let edgeWidthProportion: CGFloat = 0.12
let edgeWidth: CGFloat = boxSize * edgeWidthProportion

let nrHues: Double = 2
var currentHue: Double = Double.random(in: 0...1)
let hueVariation: Double = 0.01
let hueBasicSpeed: Double = 0.0005
let hueSpeed: Double = hueBasicSpeed + 1/nrHues
let sat: Double = 0.9
let satVariation: Double = 0.1
let brt: Double = 0.7
let brtVariation: Double = 0.3

let minAge = 10
let chanceOfDeath = 0.5
let maxAge = 20
