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
        
        self.view.backgroundColor = .white
        
        let cells = game.cellState
        
        let topCells = cells
            .filter { $0.position.vPosition == .top }
            .map { CellView(cell: $0)}
        
        let centerCells = cells
            .filter { $0.position.vPosition == .vcenter }
            .map { CellView(cell: $0)}
        
        let bottomCells = cells
            .filter { $0.position.vPosition == .bottom }
            .map { CellView(cell: $0)}
        
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
        
        cellViews = topCells + centerCells + bottomCells
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
    
    func cellViewForPosition(_ position: CellPosition) -> CellView? {
        return cellViews.first(where: { $0.cell.position == position })
    }
    
    public func cellViewPositionForPoint(point: CGPoint) -> CellPosition? {
        return cellViews.first { subview in
            let viewFrame = self.view.convert(subview.frame, from: subview.superview)
            return viewFrame.contains(point)
        }?.cell.position
    }
    
    public func highlightView(atPosition position: CellPosition) {
        let subview = cellViewForPosition(position)
        let animator = UIViewPropertyAnimator(duration: 0.1, curve: .easeIn)
        animator.addAnimations {
            subview?.backgroundColor = UIColor.red.withAlphaComponent(0.2)
        }
        animator.addCompletion { _ in
            subview?.backgroundColor = .white
        }
        animator.startAnimation()
    }
}

extension GameViewController: GameStateChangeProtocol {
    
    func gameStateChanged(game: Game) {
        let cellState = game.cellState
        cellState.forEach { cell in
            guard let cellView = self.cellViewForPosition(cell.position)
            else { return }
            cellView.cell = cell
        }
    }
}
