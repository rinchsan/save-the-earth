//
//  GameScene.swift
//  save-the-earth
//
//  Created by Masaya Hayashi on 2017/07/29.
//  Copyright © 2017年 Masaya Hayashi. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    var earth: SKSpriteNode!
    var spaceship: SKSpriteNode!

    override func didMove(to view: SKView) {
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self

        earth = childNode(withName: "earth") as! SKSpriteNode
        earth.xScale = 2
        earth.yScale = 0.5
        earth.position = CGPoint(x: frame.width / 2, y: 0)

        spaceship = SKSpriteNode(imageNamed: "spaceship")
        spaceship.scale(to: CGSize(width: frame.width / 5, height: frame.width / 5))
        spaceship.position = CGPoint(x: frame.width / 2, y: earth.frame.maxY + 50)
        addChild(spaceship)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }

    override func update(_ currentTime: TimeInterval) {
    }

}
