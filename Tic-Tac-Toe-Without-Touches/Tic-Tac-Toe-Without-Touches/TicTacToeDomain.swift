//
//  TicTacToeDomain.swift
//  Tic-Tac-Toe-Without-Touches
//
//  Created by Andrii Denysov on 30.04.2020.
//  Copyright © 2020 Readdle. All rights reserved.
//

import Foundation

enum HorizontalPosition {
    case left
    case hcenter
    case right
}

enum VerticalPosition {
    case up
    case vcenter
    case bottom
}

struct CellPosition {
    let hPosition: HorizontalPosition
    let vPosition: VerticalPosition
}

enum Player {
    case player0
    case playerX
}

enum CellState {
    case played(Player)
    case empty
}

struct Cell {
    let state: CellState
    let position: CellPosition
}

enum MoveResult {
    case playerXToMove(display:[Cell], nextMove: [Cell])
    case playerYToMove(display:[Cell], nextMove: [Cell])
    case gameWon(Player, [Cell])
    case gameTied([Cell])
}
