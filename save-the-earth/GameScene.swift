//
//  GameScene.swift
//  save-the-earth
//
//  Created by Masaya Hayashi on 2017/07/29.
//  Copyright © 2017年 Masaya Hayashi. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene {

    // MARK: - Nodes

    var earth: SKSpriteNode!
    var spaceship: SKSpriteNode!

    // MARK: - Category Bit Mask

    let spaceshipCategory: UInt32 = 0b0001
    let missileCategory: UInt32 = 0b0010
    let asteroidCategory: UInt32 = 0b0100

    // MARK: - Properties

    let motionManger = CMMotionManager()
    var acceleration: CGFloat = 0.0
    var timer: Timer? = nil

    // MARK: - Life Cycle

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

        motionManger.accelerometerUpdateInterval = 0.2
        motionManger.startAccelerometerUpdates(to: OperationQueue.current!) { (data: CMAccelerometerData?, error: Error?) in
            guard let accelerometerData = data else { return }
            let acceleration = accelerometerData.acceleration
            self.acceleration = CGFloat(acceleration.x) * 0.75 + self.acceleration * 0.25
        }

        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(addAsteroid), userInfo: nil, repeats: true)
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

    override func didSimulatePhysics() {
        let nextPasitionX = spaceship.position.x + acceleration * 50
        guard nextPasitionX > 30 else { return }
        guard nextPasitionX < frame.width - 30 else { return }
        spaceship.position.x = nextPasitionX
    }

    func addAsteroid() {
        let names = ["asteroid1", "asteroid2", "asteroid3"]
        let index = Int(arc4random_uniform(UInt32(names.count)))
        let name = names[index]
        let asteroid = SKSpriteNode(imageNamed: name)

        let random = CGFloat(arc4random_uniform(UINT32_MAX)) / CGFloat(UINT32_MAX)
        let positionX = random * frame.width
        asteroid.position = CGPoint(x: positionX, y: frame.height + asteroid.frame.height)
        asteroid.scale(to: CGSize(width: 70, height: 70))

        asteroid.physicsBody = SKPhysicsBody(circleOfRadius: asteroid.frame.width)
        asteroid.physicsBody?.isDynamic = true
        asteroid.physicsBody?.categoryBitMask = asteroidCategory
        asteroid.physicsBody?.contactTestBitMask = missileCategory + spaceshipCategory
        asteroid.physicsBody?.collisionBitMask = 0

        self.addChild(asteroid)

        let animationDuration:TimeInterval = 6
        let moveAction = SKAction.move(to: CGPoint(x: positionX, y: -asteroid.size.height), duration: animationDuration)
        let removeAction = SKAction.removeFromParent()

        asteroid.run(SKAction.sequence([moveAction, removeAction]))
    }

}
