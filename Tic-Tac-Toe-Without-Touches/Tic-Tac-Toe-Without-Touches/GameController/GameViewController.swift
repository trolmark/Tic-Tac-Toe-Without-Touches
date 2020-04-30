//
//  GameViewController.swift
//  Tic-Tac-Toe-Without-Touches
//
//  Created by Andrii Denysov on 29.04.2020.
//  Copyright © 2020 Readdle. All rights reserved.
//

import Foundation
import UIKit

final class GameViewController: UIViewController {
    
    private var cellViews: [CellView] = []
    public var game: Game
    
    init(game: Game) {
        self.game = game
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
    }
    
    func setUpUI() {
        
        self.view.backgroundColor = .blue
        
        let cells = game.gameState
        
        let topCells = cells
            .filter { $0.position.vPosition == .top }
            .map { CellView(cell: $0)}
        
        let centerCells = cells
            .filter { $0.position.vPosition == .vcenter }
            .map { CellView(cell: $0)}
        
        let bottomCells = cells
            .filter { $0.position.vPosition == .bottom }
            .map { CellView(cell: $0)}
        
        cellViews = topCells + centerCells + bottomCells
        
        let stackView = UIStackView(arrangedSubviews: [
            horizontalStack(topCells),
            horizontalStack(centerCells),
            horizontalStack(bottomCells),
        ])
        
        stackView.alignment = .fill
        stackView.spacing = 3.0
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        let stackConstraints = [
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(stackConstraints)
    }
    
    func horizontalStack(_ cellViews: [CellView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: cellViews)
        stackView.alignment = .fill
        stackView.spacing = 3.0
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
}

extension GameViewController {
    
    
}
