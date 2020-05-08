//
//  TicTacToeDomain.swift
//  Tic-Tac-Toe-Without-Touches
//
//  Created by Andrii Denysov on 30.04.2020.
//

import Foundation

enum HorizontalPosition {
    case left
    case hcenter
    case right
}

enum VerticalPosition {
    case top
    case vcenter
    case bottom
}

struct CellPosition: Equatable {
    let hPosition: HorizontalPosition
    let vPosition: VerticalPosition
    
    static func make(_ hPosition: HorizontalPosition, _ vPosition: VerticalPosition) -> Self {
        return .init(hPosition: hPosition, vPosition: vPosition)
    }
}

enum Player: Equatable {
    case player0
    case playerX
}

enum CellState: Equatable {
    case played(Player)
    case empty
}

struct Cell {
    let state: CellState
    let position: CellPosition
}

enum MoveResult {
    case playerXToMove(display:[Cell], nextMove: [Cell])
    case player0ToMove(display:[Cell], nextMove: [Cell])
    case gameWon(Player, [Cell])
    case gameTied([Cell])
}


extension Player {
    
    var textValue: String {
        switch self {
        case .player0:
            return "AI"
        case .playerX:
            return "User"
        }
    }
}
