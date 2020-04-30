//
//  SquareView.swift
//  Tic-Tac-Toe-Without-Touches
//
//  Created by Andrii Denysov on 30.04.2020.
//  Copyright © 2020 Readdle. All rights reserved.
//

import Foundation
import UIKit


class CellView: UIImageView {
    
    var cell: Cell {
        didSet {
            switch cell.state {
            case .empty:
                self.image = nil
            case .played(.playerX):
                self.image = UIImage(named: "X_symbol")
            case .played(.player0):
                self.image = UIImage(named: "O_symbol")
            }
        }
    }
    
    public init(cell: Cell) {
        self.cell = cell
        super.init(frame: .zero)
        self.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
