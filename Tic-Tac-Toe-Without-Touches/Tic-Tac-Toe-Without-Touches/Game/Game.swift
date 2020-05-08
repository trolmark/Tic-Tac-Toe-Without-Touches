//
//  Game.swift
//  Tic-Tac-Toe-Without-Touches
//
//  Created by Andrii Denysov on 30.04.2020.
//

import Foundation
import GameplayKit

protocol GameStateChangeObserver: class {
    func gameStateChanged(game: Game)
}

final class Game {
    typealias Line = [CellPosition]
    typealias GameState = [Cell]
    
    public private(set) var gameState: MoveResult {
        didSet {
            stateDidChanged()
        }
    }
    private var observations = [ObjectIdentifier : Observation]()
    
    static let allHorizPositions: [HorizontalPosition] = [.left, .hcenter, .right]
    static let allVertPositions: [VerticalPosition] = [.top, .vcenter, .bottom]
    static let emptyGameBoard: [Cell] = {
       let allPositions: [CellPosition] = allHorizPositions.flatMap { hPos in
            return allVertPositions.map { vPos in
                return .make(hPos, vPos)
            }
        }
        return allPositions.map { Cell(state: .empty, position: $0) }
    }()
    
    public var cellState: GameState {
        switch gameState {
        case .gameTied(let state):
            return state
        case .gameWon(_, let state):
            return state
        case .player0ToMove(display: let state, nextMove: _):
            return state
        case .playerXToMove(display: let state, nextMove: _):
            return state
        }
    }
        
    private init (gameState: GameState) {
        self.gameState = .playerXToMove(display: gameState, nextMove: gameState)
    }
    
    public static func newGame() -> Game {
        return Game(gameState: Game.emptyGameBoard)
    }
}
    
private extension Game {
    
    func linesToCheck() -> [Line] {
        let horizontal: [Line] = Game.allHorizPositions.compactMap { hPos in
            return Game.allVertPositions.map { vPos in
                return .make(hPos, vPos)
            }
        }
        
        let vertical: [Line] = Game.allVertPositions.compactMap { vPos in
            return Game.allHorizPositions.map { hPos in
                return .make(hPos, vPos)
            }
        }
        
        let diagonalLine1: Line = [
            .make(.left, .top),
            .make(.hcenter, .vcenter),
            .make(.right, .bottom)
        ]
        
        let diagonalLine2: Line = [
            .make(.right, .top),
            .make(.hcenter, .vcenter),
            .make(.left, .bottom)
        ]
        
        return [
            diagonalLine1,
            diagonalLine2
        ] + horizontal + vertical
    }
    
    func getCell(_ state: GameState, posToFind: CellPosition) -> Cell {
        return state.first(where: { $0.position == posToFind })!
    }
    
    func isGameWon(by player: Player, gameState: GameState) -> Bool {
        
        let cellWasPlayedBy = { (player: Player, cell: Cell) -> Bool in
            switch cell.state {
            case .empty:
                return false
            case .played(let playerToCompare):
                return playerToCompare == player
            }
        }
        
        let lineIsAllSamePlayer = { (player: Player, line: Line) -> Bool in
            return line
                .map { self.getCell(gameState, posToFind: $0) }
                .allSatisfy { cellWasPlayedBy(player, $0) == true }
        }
        
        let gameWon = linesToCheck().contains(where: { lineIsAllSamePlayer(player, $0) })
        return gameWon
    }
    
    func isGameTied(gameState: GameState) -> Bool {
        
        let cellWasPlayed = { (cell: Cell) -> Bool in
            switch cell.state {
            case .empty:
                return false
            case .played:
                return true
            }
        }
        return gameState.allSatisfy { cellWasPlayed($0) == true }
    }
    
    func otherPlayer(_ player: Player) -> Player {
        switch player {
        case .player0:
            return .playerX
        case .playerX:
            return .player0
        }
    }
    
    func remainingMoves(gameState: GameState) -> [Cell] {
        return gameState.filter { $0.state == .empty }
    }
    
    func updateCell(_ cell: Cell, gameState: GameState) -> GameState {
        return gameState.map { oldCell in
            if oldCell.position == cell.position {
                return cell
            }
            return oldCell
        }
    }
    
    private func playerMove(player: Player, movePos: CellPosition, gameState: GameState) -> MoveResult {
        let newCell: Cell = .init(state: .played(player), position: movePos)
        let newGameState = updateCell(newCell, gameState: gameState)
        
        if isGameWon(by: player, gameState: newGameState) {
            return .gameWon(player, newGameState)
        } else if isGameTied(gameState: newGameState) {
            return .gameTied(newGameState)
        } else {
            let other = otherPlayer(player)
            let availableMoves = remainingMoves(gameState: newGameState)
            switch other {
            case .player0:
                return .player0ToMove(display: newGameState, nextMove: availableMoves)
            case .playerX:
                return .playerXToMove(display: newGameState, nextMove: availableMoves)
            }
        }
    }
}

extension Game {
    
    public func availableMoves(forPlayer player: Player) -> [CellPosition] {
        switch gameState {
        case .player0ToMove(display: _, nextMove: let cellsToMove) where player == .player0:
            return cellsToMove.map { $0.position }
        case .playerXToMove(display: _, nextMove: let cellsToMove) where player == .playerX:
            return cellsToMove.map { $0.position }
        default:
            return []
        }
    }
    
    public func playerMove(player: Player, movePos: CellPosition) {
        switch gameState {
        case .gameTied( _ ):
            self.gameState = .playerXToMove(display: Game.emptyGameBoard, nextMove: Game.emptyGameBoard)
            
        case .gameWon(_ , _):
            self.gameState = .playerXToMove(display: Game.emptyGameBoard, nextMove: Game.emptyGameBoard)
            
        case let .player0ToMove(display: cells, nextMove: nextMoves) where player == .player0:
            if nextMoves.contains(where: { $0.position == movePos }) {
                gameState = playerMove(player: player, movePos: movePos, gameState: cells)
            }
            
        case let.playerXToMove(display: cells, nextMove: nextMoves) where player == .playerX:
            if nextMoves.contains(where: { $0.position == movePos }) {
                gameState = playerMove(player: player, movePos: movePos, gameState: cells)
            }
        default:
            break
        }
    }
}

private extension Game {

    struct Observation {
        weak var observer: GameStateChangeObserver?
    }
    
    func stateDidChanged() {
        for (id, observation) in observations {
            guard let observer = observation.observer else {
                observations.removeValue(forKey: id)
                continue
            }
            observer.gameStateChanged(game: self)
        }
    }
}

extension Game {
    
    func addObserver(_ observer: GameStateChangeObserver) {
        let id = ObjectIdentifier(observer)
        observations[id] = Observation(observer: observer)
    }

    func removeObserver(_ observer: GameStateChangeObserver) {
        let id = ObjectIdentifier(observer)
        observations.removeValue(forKey: id)
    }
}
