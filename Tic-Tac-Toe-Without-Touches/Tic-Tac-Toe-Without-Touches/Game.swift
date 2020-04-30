//
//  Game.swift
//  Tic-Tac-Toe-Without-Touches
//
//  Created by Andrii Denysov on 30.04.2020.
//  Copyright © 2020 Readdle. All rights reserved.
//

import Foundation

final class Game {

}

extension Game {
    
    func transformMoveResult(_ moveResult: MoveResult) -> MoveResult {
        switch moveResult {
        case .gameTied(let cells):
            return moveResult
        case .gameWon(let player, let cells):
            return moveResult
        case let .playerXToMove(display: cellToDisplay, nextMove: cellToMove):
            return .playerYToMove(display: cellToDisplay, nextMove: cellToMove)
        case let .playerYToMove(display: cellToDisplay, nextMove: cellToMove):
            return .playerXToMove(display: cellToDisplay, nextMove: cellToMove)
        }
    }
}
