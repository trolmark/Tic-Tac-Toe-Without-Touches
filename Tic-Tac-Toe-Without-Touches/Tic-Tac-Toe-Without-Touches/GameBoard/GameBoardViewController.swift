//
//  GameViewController.swift
//  Tic-Tac-Toe-Without-Touches
//
//  Created by Andrii Denysov on 29.04.2020.
//

import Foundation
import UIKit

final class GameBoardViewController: UIViewController {
    
    private var cellViews: [CellView] = []
    public var initialState: [Cell]
    
    init(gameState: [Cell]) {
        self.initialState = gameState
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        setUpUI(initialState)
    }
    
    func setUpUI(_ gameState: [Cell]) {
    
        let topCells = gameState
            .filter { $0.position.vPosition == .top }
            .map { CellView(cell: $0)}
        
        let centerCells = gameState
            .filter { $0.position.vPosition == .vcenter }
            .map { CellView(cell: $0)}
        
        let bottomCells = gameState
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

extension GameBoardViewController {
    
    func cellViewForPosition(_ position: CellPosition) -> CellView? {
        return cellViews.first(where: { $0.cell.position == position })
    }
    
    public func cellViewPositionForPoint(_ point: CGPoint) -> CellPosition? {
        let tapPoint = self.view.convert(point, to: self.view)
        return cellViews.first { subview in
            let viewFrame = self.view.convert(subview.frame, from: subview.superview)
            return viewFrame.contains(tapPoint)
        }?.cell.position
    }
}

extension GameBoardViewController: GameStateChangeObserver {
    
    func gameStateChanged(game: Game) {
        let cellState = game.cellState
        cellState.forEach { cell in
            guard let cellView = self.cellViewForPosition(cell.position)
            else { return }
            if cellView.cell.state != cell.state, cell.state != .empty {
                highlight(cellView: cellView)
            }
            cellView.cell = cell
        }
    }
    
    private func highlight(cellView: CellView) {
        let animator = UIViewPropertyAnimator(duration: 0.1, curve: .easeIn)
        animator.addAnimations {
            cellView.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
            cellView.transform = .init(scaleX: 1.1, y: 1.1)
        }
        animator.addCompletion { _ in
            cellView.backgroundColor = .white
            cellView.transform = .identity
        }
        animator.startAnimation()
    }
}
