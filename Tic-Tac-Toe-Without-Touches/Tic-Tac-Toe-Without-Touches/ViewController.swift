//
//  ViewController.swift
//  Tic-Tac-Toe-Without-Touches
//
//  Created by Andrii Denysov on 29.04.2020.
//

import UIKit
import Vision
import CoreMedia

class ViewController: UIViewController {
    
    private struct ColorConstants {
        static let gameFinishedColor = UIColor.init(red: 46 / 255, green: 139/255, blue: 87/255, alpha: 1.0)
        static let playerMoveColor = UIColor.gray.withAlphaComponent(0.5)
    }
    
    private lazy var game: Game = .newGame()
    private var turnAllowed: Bool = true
    
    private lazy var gameBoardViewController : GameBoardViewController = {
        let controller = GameBoardViewController(gameState: game.cellState)
        game.addObserver(controller)
        return controller
    }()
    
    private lazy var gestureDetectorController : GestureDetectorViewController = {
        let controller = GestureDetectorViewController()
        controller.delegate = self
        return controller
    }()
    
    private lazy var statusView: UILabel =  {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
        game.addObserver(self)
    }
    
    func setUpUI() {
        let stackView = UIStackView(arrangedSubviews: [
            gestureDetectorController.view,
            statusView,
            gameBoardViewController.view
        ])
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.distribution = .fill
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
    
        let stackConstraints = [
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        let subviewConstraints = [
            gestureDetectorController.view.heightAnchor.constraint(equalTo: gameBoardViewController.view.heightAnchor),
            statusView.heightAnchor.constraint(equalToConstant: 40)
        ]
        
        NSLayoutConstraint.activate(stackConstraints + subviewConstraints)
    }
}
    
extension ViewController: GestureDetectorControllerDelegate {
    
    func gestureControllerDetectTap(atPoint point: CGPoint, gestureDetector: GestureDetectorViewController) {
        guard let position = gameBoardViewController.cellViewPositionForPoint(point) else { return }
        makeTurn(turn: position)
    }
    
    func makeTurn(turn: CellPosition) {
        guard turnAllowed else { return }
        turnAllowed = false
        
        game.playerMove(player: .playerX, movePos: turn)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Make simple strategy for AI :  pick random position from allowed moves
            let moves = self.game.availableMoves(forPlayer: .player0)
            guard let aiPosition = moves.randomElement() else { return }
            self.game.playerMove(player: .player0, movePos: aiPosition)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.turnAllowed = true
        }
    }
}

extension ViewController: GameStateChangeObserver {

    func gameStateChanged(game: Game) {
        switch game.gameState {
        case .gameTied:
            statusView.backgroundColor = ColorConstants.gameFinishedColor
            statusView.text = "Game Tied"
        case .gameWon(let player, _):
            statusView.backgroundColor = ColorConstants.gameFinishedColor
            statusView.text = "Game won by \(player.textValue)"
        case .player0ToMove:
            statusView.backgroundColor = ColorConstants.playerMoveColor
            statusView.text = "AI turn"
        case .playerXToMove:
            statusView.backgroundColor = ColorConstants.playerMoveColor
            statusView.text = "User turn"
        }
    }
}

