//
//  MineMap.swift
//  Final Project_MoLab
//
//  Created by 项一诺 on 12/7/23.
//
 
import UIKit

class MineMapViewController: UIViewController, DiceRollDelegate {
    let gridSize = 5 // Adjust the size of the grid as needed
    var mineMap = [[Bool]]()
    var playerPosition: (x: Int, y: Int)!
    var diceRollCounter: Int = 0 // Add dice roll counter
    let startingPositionColor = UIColor.green // Color for the starting position
    var gridContainerView: UIView! // Container view for the grid
    var playerView: UIView! // View representing the player
    var diceRollLabel: UILabel! // Label for the dice roll counter
    var diceViewController: DiceViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createGrid()
        placeMines()
        playerPosition = (Int.random(in: 0..<gridSize), Int.random(in: 0..<gridSize))
        addDirectionButtons()
        visualizeGrid() // Move this line here
        // Create a label for the dice roll counter
               diceRollLabel = UILabel()
               diceRollLabel.textAlignment = .center
               diceRollLabel.font = UIFont.systemFont(ofSize: 24)
               diceRollLabel.text = "Dice Rolls: \(diceRollCounter)"
               diceRollLabel.translatesAutoresizingMaskIntoConstraints = false
               view.addSubview(diceRollLabel)

               NSLayoutConstraint.activate([
                   diceRollLabel.bottomAnchor.constraint(equalTo: gridContainerView.bottomAnchor, constant: -20),
                   diceRollLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
               ])
        // Create or present the DiceViewController
          diceViewController = DiceViewController()
          if let diceViewController = diceViewController {
              diceViewController.delegate = self
              present(diceViewController, animated: true, completion: nil)
          }
       }
    
    func addDirectionButtons() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        stackView.spacing = 8.0
        
        let directions = ["Up", "Down", "Left", "Right"]
        for direction in directions {
            let button = UIButton(type: .system)
            button.setTitle(direction, for: .normal)
            button.addTarget(self, action: #selector(directionButtonPressed(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
        
        // Add restart button
        let restartButton = UIButton(type: .system)
        restartButton.setTitle("Restart", for: .normal)
        restartButton.addTarget(self, action: #selector(restartButtonPressed), for: .touchUpInside)
        stackView.addArrangedSubview(restartButton)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20.0)
        ])
        
        // Create a container view for the grid
        gridContainerView = UIView()
        gridContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gridContainerView)
        
        NSLayoutConstraint.activate([
            gridContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gridContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gridContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            gridContainerView.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -20.0)
        ])


        
        // Create a view representing the player
        playerView = UIView()
        playerView.backgroundColor = startingPositionColor
        playerView.layer.borderWidth = 1.0
        playerView.layer.borderColor = UIColor.black.cgColor
        gridContainerView.addSubview(playerView)
    }
    
    // Implement the DiceRollDelegate method
    func didRollDice(_ result: Int) {
        // Update the label text
        diceRollLabel.text = "Dice Rolls: \(result)"
        print("Dice rolled. New counter: \(result)")

        // existing code...
        if result >= 10 {
            showWinNotification()
        }
    }
    
    
    @objc func directionButtonPressed(_ sender: UIButton) {
        guard let direction = sender.title(for: .normal) else { return }
        let lowercaseDirection = direction.lowercased()
        movePlayer(steps: 1, direction: lowercaseDirection) // Change the number of steps as needed
    }
    
    // Inside the movePlayer function:
    func movePlayer(steps: Int, direction: String) {
        var newPosition = playerPosition
        
        switch direction {
        case "up":
            newPosition?.y = max(0, (playerPosition?.y ?? 0) - steps)
        case "down":
            newPosition?.y = min(gridSize - 1, (playerPosition?.y ?? 0) + steps)
        case "left":
            newPosition?.x = max(0, (playerPosition?.x ?? 0) - steps)
        case "right":
            newPosition?.x = min(gridSize - 1, (playerPosition?.x ?? 0) + steps)
        default:
            break
        }
        
        if let newPosition = newPosition {
            playerPosition = newPosition
            if mineMap[playerPosition.x][playerPosition.y] {
                showGameOverAlert()
            } else {
                print("Current Position: (\(playerPosition.x), \(playerPosition.y))")
                visualizeGrid() // Update the grid visualization after moving
            }
        }
    }
    
    
    
    func showWinNotification() {
           let notificationCenter = UNUserNotificationCenter.current()

           let content = UNMutableNotificationContent()
           content.title = "Congratulations!"
           content.body = "You won the game by avoiding mines!"
           content.sound = UNNotificationSound.default

           let request = UNNotificationRequest(identifier: "winNotification", content: content, trigger: nil)
           notificationCenter.add(request) { (error) in
               if let error = error {
                   print("Error adding notification request: \(error)")
               }
           }
       }
    
    func showGameOverAlert() {
        let alertController = UIAlertController(title: "Game Over", message: "You stepped on a mine! Would you like to restart?", preferredStyle: .alert)
        
        let restartAction = UIAlertAction(title: "Restart", style: .default) { _ in
            self.restartGame()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(restartAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
        // Check if the player has successfully navigated without stepping on any mines
        if !mineMap.contains(where: { row in row.contains(true) }) {
            // Player has won
            showWinNotification()
        }
    }

    
    
    @objc func restartButtonPressed() {
        restartGame()
    }
    
    func restartGame() {
        createGrid()
        placeMines()
        
        // Regenerate the player's initial position until it is not on a mine
        repeat {
            playerPosition = (Int.random(in: 0..<gridSize), Int.random(in: 0..<gridSize))
        } while mineMap[playerPosition.x][playerPosition.y]
        
        visualizeGrid()
    }
    
    
    func createGrid() {
        // Initialize the grid
        mineMap = [[Bool]](repeating: [Bool](repeating: false, count: gridSize), count: gridSize)
    }
    
    func placeMines() {
        // Randomly place mines on the map
        for _ in 0..<min(gridSize * gridSize / 8, 10) {
            let x = Int.random(in: 0..<gridSize)
            let y = Int.random(in: 0..<gridSize)
            mineMap[x][y] = true
        }
    }
    
    
    func visualizeGrid() {
        let cellSize = gridContainerView.frame.width / CGFloat(gridSize)

        // Remove existing cell views from the grid container
        gridContainerView.subviews.forEach { $0.removeFromSuperview() }

        // Update player view position
        let playerLabel = UILabel(frame: CGRect(x: CGFloat(playerPosition.x) * cellSize,
                                                y: CGFloat(playerPosition.y) * cellSize,
                                                width: cellSize,
                                                height: cellSize))
        playerLabel.text = "🚩" // emoji
        playerLabel.font = UIFont.systemFont(ofSize: 50.0)
        playerLabel.textAlignment = .center
        gridContainerView.addSubview(playerLabel)

        for x in 0..<gridSize {
            for y in 0..<gridSize {
                if mineMap[x][y] {
                    let mineLabel = UILabel(frame: CGRect(x: CGFloat(x) * cellSize,
                                                          y: CGFloat(y) * cellSize,
                                                          width: cellSize,
                                                          height: cellSize))
                    mineLabel.text = "💣" // Bomb emoji
                    mineLabel.font = UIFont.systemFont(ofSize: 50.0)
                    mineLabel.textAlignment = .center
                    gridContainerView.addSubview(mineLabel)
                } else if playerPosition.x == x && playerPosition.y == y {
                    // Player view is already added, skip here
                } else {
                    let cellView = UIView(frame: CGRect(x: CGFloat(x) * cellSize,
                                                        y: CGFloat(y) * cellSize,
                                                        width: cellSize,
                                                        height: cellSize))
                    cellView.backgroundColor = UIColor.black
                    cellView.layer.borderWidth = 1.0
                    cellView.layer.borderColor = UIColor.white.cgColor
                    gridContainerView.addSubview(cellView)
                }
            }
        }
    }

}
