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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
    }
    
    func setUpUI() {
        self.view.backgroundColor = .blue
    }
}
