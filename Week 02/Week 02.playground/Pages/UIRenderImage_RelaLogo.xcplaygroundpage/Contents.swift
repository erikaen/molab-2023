//: [Previous](@previous)
/*:
 # Image Render #2 Rela Logo
 This is an 1024 x 1024 image.
 */

import UIKit

let dim = 1024.0

let renderer = UIGraphicsImageRenderer(size: CGSize(width: dim*3, height: dim))

var image = renderer.image { (context) in
    UIColor.darkGray.setStroke()
    let rt = renderer.format.bounds
    context.stroke(rt)
    
    let x = rt.width * 0.5
    let y = 0.0
        
    let font = UIFont.systemFont(ofSize: rt.height * 0.8)
    
    let string = NSAttributedString(string: "😉", attributes: [.font: font ])
    string.draw(at: CGPoint(x: x, y: y))
    
    // Draw a background
    let mintGreen = UIColor(red: 2/255, green: 210/255, blue: 200/255, alpha: 1.0)
    let Rect = CGRect(x: 220, y: 180, width: 600, height: 600)
    mintGreen.setFill()
    context.fill(Rect)
    
    // Draw a circle for the face
      UIColor.white.setFill()
      let faceRect = CGRect(x: 270, y: 230, width: 500, height: 500)
      context.cgContext.fillEllipse(in: faceRect)

      // Draw the left eye (curve)
      mintGreen.setStroke()
      let leftEyePath = UIBezierPath()
      leftEyePath.move(to: CGPoint(x: 350, y: 450))
      leftEyePath.addQuadCurve(to: CGPoint(x: 500, y: 450), controlPoint: CGPoint(x: 430, y: 380))
      leftEyePath.lineWidth = 35
      leftEyePath.stroke()

      // Draw the right eye ("<")
       context.cgContext.setLineWidth(35)
       context.cgContext.move(to: CGPoint(x: 664, y: 380))
       context.cgContext.addLine(to: CGPoint(x: 570, y: 430))
       context.cgContext.move(to: CGPoint(x: 570, y: 430))
       context.cgContext.addLine(to: CGPoint(x: 664, y: 480))
       context.cgContext.strokePath()
      
      // Draw a curve for the mouth
      let mouthPath = UIBezierPath()
      mouthPath.move(to: CGPoint(x: 410, y: 560))
      mouthPath.addQuadCurve(to: CGPoint(x: 630, y: 560), controlPoint: CGPoint(x: 520, y: 680))
      mouthPath.lineWidth = 35
      mouthPath.stroke()
}

image

//: [Next](@next)
