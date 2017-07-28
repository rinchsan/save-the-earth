//
//  GameScene.swift
//  save-the-earth
//
//  Created by Masaya Hayashi on 2017/07/29.
//  Copyright © 2017年 Masaya Hayashi. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {

    var earth: SKSpriteNode!
    var spaceship: SKSpriteNode!

    let spaceshipCategory: UInt32 = 0b0001
    let missileCategory: UInt32 = 0b0010
    let asteroidCategory: UInt32 = 0b0100

    override func didMove(to view: SKView) {
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)

        earth = childNode(withName: "earth") as! SKSpriteNode
        earth.xScale = 2
        earth.yScale = 0.5
        earth.position = CGPoint(x: frame.width / 2, y: 0)

        spaceship = SKSpriteNode(imageNamed: "spaceship")
        spaceship.scale(to: CGSize(width: frame.width / 5, height: frame.width / 5))
        spaceship.position = CGPoint(x: frame.width / 2, y: earth.frame.maxY + 50)
        addChild(spaceship)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let missile = SKSpriteNode(imageNamed: "missile")
        missile.position = CGPoint(x: spaceship.position.x, y: spaceship.position.y + 10)
        missile.physicsBody = SKPhysicsBody(circleOfRadius: missile.frame.height / 2)
        missile.physicsBody?.isDynamic = true
        missile.physicsBody?.categoryBitMask = missileCategory
        missile.physicsBody?.contactTestBitMask = asteroidCategory
        missile.physicsBody?.collisionBitMask = 0
        addChild(missile)

        let moveToTop = SKAction.moveTo(y: frame.height + 10, duration: 0.3)
        let remove = SKAction.removeFromParent()
        missile.run(SKAction.sequence([moveToTop, remove]))
    }

    override func update(_ currentTime: TimeInterval) {
    }

}
