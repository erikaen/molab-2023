//
//  MineMap.swift
//  Final Project_MoLab
//
//  Created by 项一诺 on 12/7/23.
//
 
import UIKit
import SwiftUI
import Combine

class MineMapViewController: UIViewController, DiceRollDelegate {
    var diceRollState: DiceRollState
    init(diceRollState: DiceRollState) {
        self.diceRollState = diceRollState
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    let gridSize = 5 // Adjust the size of the grid as needed
    var mineMap = [[Bool]]()
    var playerPosition: (x: Int, y: Int)!
    var diceRollCounter: Int = 0 // Add dice roll counter
    let startingPositionColor = UIColor.green // Color for the starting position
    var gridContainerView: UIView! // Container view for the grid
    var playerView: UIView! // View representing the player
    var diceRollLabel: UILabel! // Label for the dice roll counter
    var diceViewController: DiceViewController?
    var isGameOver = false
    
    
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
        diceViewController = DiceViewController(diceRollState: diceRollState)
        diceViewController?.delegate = self
        present(diceViewController!, animated: true, completion: nil)

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
        diceRollCounter = result
        diceRollLabel.text = "Steps Remaining: \(diceRollCounter)"
    }

    
    
    @objc func directionButtonPressed(_ sender: UIButton) {
        guard diceRollCounter > 0 else {
            // No more steps left
            checkGameStatus()
            return
        }

        guard let direction = sender.title(for: .normal)?.lowercased() else { return }

        movePlayer(steps: 1, direction: direction)
        diceRollCounter -= 1
        diceRollLabel.text = "Steps Remaining: \(diceRollCounter)"

        if diceRollCounter == 0 {
            checkGameStatus()
        }
    }
    
    func checkGameStatus() {
        if mineMap[playerPosition.x][playerPosition.y] {
            // Player stepped on a mine
            showGameOverAlert()
        } else if diceRollCounter == 0 {
            // Player used all steps and did not step on a mine
            showWinNotification()
        } else {
            // Game continues, player still has steps remaining
            // You can update the UI to reflect the remaining steps
        }
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
        isGameOver = true
        let alertController = UIAlertController(title: "Congratulations!", message: "You won the game by avoiding mines!", preferredStyle: .alert)
        
        let restartAction = UIAlertAction(title: "Restart", style: .default) { _ in
            self.restartGame()
        }
        
        let cancelAction = UIAlertAction(title: "Close", style: .cancel, handler: nil)
        
        alertController.addAction(restartAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true) {
                self.visualizeGrid() // Reveal the mine map after presenting the alert
            }
    }

    
    func showGameOverAlert() {
        isGameOver = true
        let alertController = UIAlertController(title: "Game Over", message: "You stepped on a mine! Would you like to restart?", preferredStyle: .alert)
        
        let restartAction = UIAlertAction(title: "Restart", style: .default) { _ in
            self.restartGame()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(restartAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true) {
               self.visualizeGrid() // Reveal the mine map after presenting the alert
           }
        
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
        isGameOver = false
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

        for x in 0..<gridSize {
            for y in 0..<gridSize {
                let cellFrame = CGRect(x: CGFloat(x) * cellSize, y: CGFloat(y) * cellSize, width: cellSize, height: cellSize)

                if isGameOver && mineMap[x][y] {
                    // Show mines if game is over
                    let mineLabel = UILabel(frame: cellFrame)
                    mineLabel.text = "💣" // Bomb emoji
                    mineLabel.font = UIFont.systemFont(ofSize: 50.0)
                    mineLabel.textAlignment = .center
                    gridContainerView.addSubview(mineLabel)
                } else if x == playerPosition.x && y == playerPosition.y {
                    // Always show player position
                    let playerLabel = UILabel(frame: cellFrame)
                    playerLabel.text = "🚩" // Player emoji
                    playerLabel.font = UIFont.systemFont(ofSize: 50.0)
                    playerLabel.textAlignment = .center
                    gridContainerView.addSubview(playerLabel)
                } else {
                    // Add an empty cell
                    let cellView = UIView(frame: cellFrame)
                    cellView.backgroundColor = UIColor.black
                    cellView.layer.borderWidth = 1.0
                    cellView.layer.borderColor = UIColor.white.cgColor
                    gridContainerView.addSubview(cellView)
                }
            }
        }
    }


}
