//
//  ContentView.swift
//  Final Project_MoLab
//
//  Created by 项一诺 on 11/30/23.
//

import UIKit
import CoreMotion
import SceneKit

class DiceViewController: UIViewController {

    let motionManager = CMMotionManager()
    var sceneView: SCNView!
    var scene: SCNScene!
    var diceNode: SCNNode!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create a SceneKit view
        sceneView = SCNView(frame: view.bounds)
        sceneView.backgroundColor = UIColor.white
        view.addSubview(sceneView)

        // Create a 3D scene
        scene = SCNScene()
        sceneView.scene = scene
        
        // Add ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor(white: 5, alpha: 1.0) // Adjust intensity as needed
        scene.rootNode.addChildNode(ambientLightNode)
        
        // Create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: -5, z: 100)
        scene.rootNode.addChildNode(cameraNode)

        // Set the camera as the point of view for the scene
        sceneView.pointOfView = cameraNode
        
        // Load a 3D model
        if let modelURL = Bundle.main.url(forResource: "dice", withExtension: "dae") {
            if let modelScene = try? SCNScene(url: modelURL, options: nil) {
                // Create a node to hold the loaded model
                diceNode = SCNNode()
                for childNode in modelScene.rootNode.childNodes {
                    childNode.scale = SCNVector3(0.1, 0.1, 0.1)
                    diceNode.addChildNode(childNode)
                }

                // Position and scale the model node based on screen size
                let screenFrame = sceneView.frame
                let screenScale = min(screenFrame.width, screenFrame.height) / 3.0  // Adjust the scale factor as needed
                diceNode.position = SCNVector3(0, 0, 0)
                diceNode.scale = SCNVector3(screenScale, screenScale, screenScale)

                
            
                // Add the model node to the scene
                scene.rootNode.addChildNode(diceNode)

                // Configure motion updates
                if motionManager.isAccelerometerAvailable {
                    motionManager.accelerometerUpdateInterval = 1.0 / 60.0  // 60 Hz
                    motionManager.startAccelerometerUpdates(to: .main) { [weak self] (accelerometerData, error) in
                        guard let accelerometerData = accelerometerData, error == nil else { return }
                        self?.handleAccelerometerUpdate(accelerometerData.acceleration)
                    }
                }
            }
        }
    }
    
    
    

    func handleAccelerometerUpdate(_ acceleration: CMAcceleration) {
           let accelerationThreshold = 2.5  // Adjust this value as needed

           if abs(acceleration.x) > accelerationThreshold ||
              abs(acceleration.y) > accelerationThreshold ||
              abs(acceleration.z) > accelerationThreshold {
               startDiceRolling()
           }
       }

       func startDiceRolling() {
           // Roll the dice for two seconds
           rollDice()
       }

       func rollDice() {
           // Choose a random face to simulate
           let faces: [SCNVector4] = [
               SCNVector4(0, 0, 1, CGFloat.pi * 2),      // Rotate 180 degrees around Z-axis
               SCNVector4(0, 1, 0, CGFloat.pi * 2),      // Rotate 180 degrees around Y-axis
               SCNVector4(1, 0, 0, CGFloat.pi * 2),      // Rotate 180 degrees around X-axis
               SCNVector4(0, 1, 0, CGFloat.pi / 2),  // Rotate 90 degrees around Y-axis
               SCNVector4(0, 1, 0, -CGFloat.pi / 2)  // Rotate -90 degrees around Y-axis
           ]
           let randomFace = faces.randomElement() ?? SCNVector4(0, 0, 0, 0)

           // Apply a force to simulate rolling
           let rollAction = SCNAction.rotate(toAxisAngle: randomFace, duration: 1.5)
           diceNode.runAction(rollAction, forKey: "rollAction")
       }

       override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
           // Start rolling the dice when motion ends
           if motion == .motionShake {
               startDiceRolling()
           }
       }
   }
