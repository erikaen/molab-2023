//: [Previous](@previous)
/*:
 # Image Render #1 Butterfly
 This is an 1024 x 1024 image.
 */
import UIKit

// Create the size
let renderer = UIGraphicsImageRenderer(size: CGSize(width: 1024, height: 1024))

// Create a shape
let image = renderer.image { (context) in
    // Draw a rainbow background
    let rainbowColors: [UIColor] = [
        UIColor.red,
        UIColor.orange,
        UIColor.yellow,
        UIColor.green,
        UIColor.blue,
        UIColor.purple
    ]
    
    let rectHeight = 1024.0 / Double(rainbowColors.count)
    for (index, color) in rainbowColors.enumerated() {
        let rect = CGRect(x: 0, y: Double(index) * rectHeight, width: 1024, height: rectHeight)
        color.setFill()
        context.fill(rect)
    }
    
    // Left upper wing
    let leftWingColor = UIColor(red: 158/255, green: 215/255, blue: 245/255, alpha: 1)
    leftWingColor.setFill()
    let leftWingPath = UIBezierPath()
    leftWingPath.move(to: CGPoint(x: 512, y: 500))
    leftWingPath.addCurve(to: CGPoint(x: 50, y: 200), controlPoint1: CGPoint(x: 100, y: 450), controlPoint2: CGPoint(x: 350, y: 100))
    leftWingPath.addCurve(to: CGPoint(x: 512, y: 500), controlPoint1: CGPoint(x: 50, y: 100), controlPoint2: CGPoint(x: 450, y: 200))
    leftWingPath.fill()
    
    // Left lower wing
    let leftWingColor1 = UIColor(red: 158/255, green: 215/255, blue: 245/255, alpha: 1)
    leftWingColor1.setFill()
    let leftWingPath1 = UIBezierPath()
    leftWingPath1.move(to: CGPoint(x: 512, y: 500)) // Starting point (lowered)
    leftWingPath1.addCurve(to: CGPoint(x: 300, y: 800), controlPoint1: CGPoint(x: 200, y: 400), controlPoint2: CGPoint(x: 350, y: 700))
    leftWingPath1.addCurve(to: CGPoint(x: 512, y: 500), controlPoint1: CGPoint(x: 250, y: 900), controlPoint2: CGPoint(x: 450, y: 550))
    leftWingPath1.fill()

    // Right upper wing
    let rightWingColor = UIColor(red: 180/255, green: 185/255, blue: 245/255, alpha: 1)
    rightWingColor.setFill()
    let rightWingPath = UIBezierPath()
    rightWingPath.move(to: CGPoint(x: 512, y: 500))
    rightWingPath.addCurve(to: CGPoint(x: 974, y: 200), controlPoint1: CGPoint(x: 924, y: 450), controlPoint2: CGPoint(x: 674, y: 100))
    rightWingPath.addCurve(to: CGPoint(x: 512, y: 500), controlPoint1: CGPoint(x: 974, y: 100), controlPoint2: CGPoint(x: 574, y: 200))
    rightWingPath.fill()

    // Right lower wing
    let rightWingColor1 = UIColor(red: 180/255, green: 185/255, blue: 245/255, alpha: 1)
    rightWingColor1.setFill()
    let rightWingPath1 = UIBezierPath()
    rightWingPath1.move(to: CGPoint(x: 512, y: 500)) // Starting point (lowered)
    rightWingPath1.addCurve(to: CGPoint(x: 724, y: 800), controlPoint1: CGPoint(x: 824, y: 400), controlPoint2: CGPoint(x: 674, y: 700))
    rightWingPath1.addCurve(to: CGPoint(x: 512, y: 500), controlPoint1: CGPoint(x: 774, y: 900), controlPoint2: CGPoint(x: 574, y: 550))
    rightWingPath1.fill()

    // Head and Body of the butterfly
    UIColor.brown.setFill()
    let headPath = UIBezierPath(ovalIn: CGRect(x: 482, y: 400, width: 60, height: 60))
    headPath.fill()
    UIColor.brown.setFill()
    let bodyPath = UIBezierPath(ovalIn: CGRect(x: 482, y:460, width: 60, height: 200))
    bodyPath.fill()

    // Antennae
    UIColor.black.setStroke()
    context.cgContext.setLineWidth(4) // Set line width for the current graphics context
    context.cgContext.move(to: CGPoint(x: 512, y: 400))
    context.cgContext.addLine(to: CGPoint(x: 460, y: 200))
    context.cgContext.move(to: CGPoint(x: 512, y: 400))
    context.cgContext.addLine(to: CGPoint(x: 564, y: 200))
    context.cgContext.strokePath()
}


image


//: [Next](@next)
