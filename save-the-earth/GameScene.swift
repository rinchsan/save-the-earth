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

class GameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - Nodes

    var earth: SKSpriteNode!
    var spaceship: SKSpriteNode!
    var life: [SKSpriteNode] = [SKSpriteNode]()
    var scoreLabel: SKLabelNode!

    // MARK: - Category Bit Mask

    let spaceshipCategory: UInt32 = 0b0001
    let missileCategory: UInt32 = 0b0010
    let asteroidCategory: UInt32 = 0b0100
    let earthCategory: UInt32 = 0b1000

    // MARK: - Properties

    let motionManger = CMMotionManager()
    var acceleration: CGFloat = 0.0
    var timer: Timer? = nil
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var vc: GameViewController!

    // MARK: - Life Cycle

    override func didMove(to view: SKView) {
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self

        earth = childNode(withName: "earth") as! SKSpriteNode
        earth.xScale = 2
        earth.yScale = 0.5
        earth.position = CGPoint(x: frame.width / 2, y: 0)
        earth.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: frame.width, height: 100))
        earth.physicsBody?.isDynamic = true
        earth.physicsBody?.categoryBitMask = earthCategory
        earth.physicsBody?.contactTestBitMask = asteroidCategory
        earth.physicsBody?.collisionBitMask = 0
        earth.zPosition = -1

        spaceship = SKSpriteNode(imageNamed: "spaceship")
        spaceship.scale(to: CGSize(width: frame.width / 5, height: frame.width / 5))
        spaceship.position = CGPoint(x: frame.width / 2, y: earth.frame.maxY + 50)
        spaceship.physicsBody = SKPhysicsBody(circleOfRadius: spaceship.size.width * 0.1)
        spaceship.physicsBody?.isDynamic = true
        spaceship.physicsBody?.categoryBitMask = spaceshipCategory
        spaceship.physicsBody?.contactTestBitMask = asteroidCategory
        spaceship.physicsBody?.collisionBitMask = 0
        addChild(spaceship)

        motionManger.accelerometerUpdateInterval = 0.2
        motionManger.startAccelerometerUpdates(to: OperationQueue.current!) { (data: CMAccelerometerData?, error: Error?) in
            guard let accelerometerData = data else { return }
            let acceleration = accelerometerData.acceleration
            self.acceleration = CGFloat(acceleration.x) * 0.75 + self.acceleration * 0.25
        }

        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(addAsteroid), userInfo: nil, repeats: true)

        for i in 1...5 {
            let heart = SKSpriteNode(imageNamed: "heart")
            heart.position = CGPoint(x: heart.frame.height * CGFloat(i), y: frame.height - heart.frame.height)
            addChild(heart)
            life.append(heart)
        }

        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.fontName = "Papyrus"
        scoreLabel.fontSize = 50
        scoreLabel.position = CGPoint(x: scoreLabel.frame.width / 2 + 50, y: frame.height - scoreLabel.frame.height * 5)
        addChild(scoreLabel)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isPaused else { return }
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

        let moveAction = SKAction.move(to: CGPoint(x: positionX, y: -asteroid.size.height), duration: 6.0)
        asteroid.run(moveAction)
    }

    func didBegin(_ contact: SKPhysicsContact) {
        var asteroid: SKPhysicsBody
        var collisionTarget: SKPhysicsBody
        if contact.bodyA.categoryBitMask == asteroidCategory {
            asteroid = contact.bodyA
            collisionTarget = contact.bodyB
        } else {
            asteroid = contact.bodyB
            collisionTarget = contact.bodyA
        }

        let asteroidNode = asteroid.node as! SKSpriteNode
        let collisionTargetNode = collisionTarget.node as! SKSpriteNode

        guard let explosion = SKEmitterNode(fileNamed: "Explosion") else { return }
        explosion.position = asteroidNode.position
        addChild(explosion)

        asteroidNode.removeFromParent()
        if collisionTarget.categoryBitMask == missileCategory {
            collisionTargetNode.removeFromParent()
        }

        self.run(SKAction.wait(forDuration: 1.0)) {
            explosion.removeFromParent()
        }

        switch collisionTarget.categoryBitMask {
        case spaceshipCategory, earthCategory:
            guard let heart = life.last else { return }
            heart.removeFromParent()
            life.removeLast()
            if life.isEmpty { showResult() }
        case missileCategory:
            score += 5
        default:
            fatalError()
        }
    }

    func showResult() {
        isPaused = true
        timer?.invalidate()
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            self.vc.dismiss(animated: true, completion: nil)
        }
    }

}
