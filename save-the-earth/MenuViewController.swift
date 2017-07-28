//
//  MenuViewController.swift
//  save-the-earth
//
//  Created by Masaya Hayashi on 2017/07/29.
//  Copyright © 2017年 Masaya Hayashi. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet weak var bestScoreLabel: UILabel!

    var bestScore: Int! {
        didSet {
            guard let score = bestScore else { return }
            self.bestScoreLabel.text = "Best Score: \(score)"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.bestScore = 0
    }

}
