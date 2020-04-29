//
//  ViewController.swift
//  Tic-Tac-Toe-Without-Touches
//
//  Created by Andrii Denysov on 29.04.2020.
//  Copyright © 2020 Readdle. All rights reserved.
//

import UIKit
import Vision
import CoreMedia

class ViewController: UIViewController {
    
    private let stackView = UIStackView()
    private lazy var gameViewController : GameViewController = {
        return GameViewController()
    }()
    private lazy var gestureDetectorController : GestureDetectorViewController = {
        return GestureDetectorViewController()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setUpUI() {
        stackView.alignment = .fill
        stackView.spacing = 8.0
        stackView.axis = .vertical
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
    
        let stackConstraints = [
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
            
        NSLayoutConstraint.activate(stackConstraints)
        
        addDisplayController(gestureDetectorController, to: stackView)
        addDisplayController(gameViewController, to: stackView)
    }
    
    private func addDisplayController(_ child: UIViewController, to stackView: UIStackView) {
        addChild(child)
        stackView.addArrangedSubview(child.view)
        child.didMove(toParent: self)
    }
}
    


