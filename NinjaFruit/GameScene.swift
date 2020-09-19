//
//  GameScene.swift
//  NinjaFruit
//
//  Created by Solomon Chai on 2020-08-14.
//  Copyright © 2020 Solomon Chai. All rights reserved.
//

import SpriteKit
import GameplayKit

enum GamPhase {
    case Ready
    case InPlay
    case GameOver
}

class GameScene: SKScene {
    
    var gamePhase = GamPhase.Ready
    var score = 0
    var best = 0
    var missCount = 0
    var maxMiss = 3
    var maxCombo = 0
    var combo = 0
    
    var promptLabel = SKLabelNode()
    var scoreLabel = SKLabelNode()
    var bestLabel = SKLabelNode()
    var pauseButton = SKLabelNode()
    var pausedLabel = SKLabelNode()
    var comboLabel = SKLabelNode()
    var maxComboLabel = SKLabelNode()
    
    var fruitThrowTimer = Timer()
    
    var xMarks = XMarks()
    var explodeOverlay = SKShapeNode()
    
    override func didMove(to view: SKView) {

        scoreLabel = childNode(withName: "score label") as! SKLabelNode
        scoreLabel.text = "\(score)"
        
        bestLabel = childNode(withName: "best label") as! SKLabelNode
        bestLabel.text = "Best: \(best)"
        
        maxComboLabel = childNode(withName: "max combo label") as! SKLabelNode
        maxComboLabel.text = "Max combo: \(maxCombo)"
        
        
        promptLabel = childNode(withName: "prompt label") as! SKLabelNode
        pauseButton = childNode(withName: "pause label") as! SKLabelNode
        pausedLabel = childNode(withName: "paused") as! SKLabelNode
        comboLabel = childNode(withName: "combo label") as! SKLabelNode
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -3)
        
        comboLabel.text = "\(combo)"
        comboLabel.isHidden = true
        pausedLabel.isHidden = true
        maxComboLabel.isHidden = true
        xMarks = XMarks(num: maxMiss)
        xMarks.position = CGPoint(x: size.width-60, y: size.height-60)
        addChild(xMarks)
        
        explodeOverlay = SKShapeNode(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        explodeOverlay.fillColor = .white
        addChild(explodeOverlay)
        explodeOverlay.alpha = 0
        
        //load data
        if UserDefaults.standard.object(forKey: "best") != nil {
            best = UserDefaults.standard.object(forKey: "best") as! Int
        }
        if UserDefaults.standard.object(forKey: "maxCombo") != nil {
            maxCombo = UserDefaults.standard.object(forKey: "maxCombo") as! Int
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gamePhase == .Ready {
            gamePhase = .InPlay
            startGame()
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let location = t.location(in: self)
            let previousLocation = t.previousLocation(in: self)
            comboLabel.isHidden = false
            maxComboLabel.isHidden = false
            
            for node in nodes(at: location) {
                if node.name == "fruit" {
                    score += 1
                    scoreLabel.text = "\(score)"
                    node.removeFromParent()
                    particleEffect(position: node.position)
                    combo += 1
                    comboLabel.text = "\(combo)"
                    particleEffect(position: comboLabel.position)
                    if combo > maxCombo {
                        maxCombo = combo
                    }
                    maxComboLabel.text = "Max combo: \(maxCombo)"
                    UserDefaults.standard.set(maxCombo, forKey: "maxCombo")
                    UserDefaults.standard.synchronize()
                    //exploding effect
                    //sound effect
                    
                    //let n = 1 + Int(arc4random_uniform(UInt32(6)))
                    //playSoundEffect(soundFile: "sound/squish\(n).mp3")
                }
                if node.name == "bomb" {
                    bombExplode()
                    gameOver()
                    particleEffect(position: node.position)
                    combo = 0
                    
                    //playSoundEffect(soundFile: "sound/kboom.mp3")
                }
                if node.name == "pause label" {
                    pauseGame(isPaused: scene?.view?.isPaused)
                }
            }
            let line = TrailLine(position: location, lastPosition: previousLocation, width: 15, color: .white)
            addChild(line)
        }
    }
    
    override func didSimulatePhysics() {
        for fruit in children {
            if fruit.position.y < -100 {
                fruit.removeFromParent()
                if fruit.name == "fruit" {
                    missFruit()
                }
            }
        }
    }
    
    func startGame() {
        score = 0
        scoreLabel.text = "\(score)"
        bestLabel.text = "Best: \(best)"
        combo = 0
        comboLabel.text = "\(combo)"
        missCount = 0
        
        xMarks.reset()
        
        promptLabel.isHidden = true
        
        fruitThrowTimer = Timer.scheduledTimer(withTimeInterval: score > 50 ? 0.8 : 1.5, repeats: true, block: {_ in self.createFruits()})
    }
    
    func createFruits() {
        
        let numberOfFruits = Int(arc4random_uniform(UInt32(4)))
        
        for _ in 0..<numberOfFruits {
            
            let fruit = Fruit()
            fruit.position.x = randomCGFlaot(0, size.width)
            fruit.position.y = -100
            addChild(fruit)
            
            if fruit.position.x < size.width/2 {
                fruit.physicsBody?.velocity.dx = randomCGFlaot(0, 200)
            }
            
            if fruit.position.x > size.width/2 {
                fruit.physicsBody?.velocity.dx = randomCGFlaot(0, -200)
            }
            
            fruit.physicsBody?.velocity.dy = randomCGFlaot(600, 800)
            fruit.physicsBody?.angularVelocity = randomCGFlaot(-5, 5)
        }
    }
    
    func missFruit() {
        missCount += 1
        combo = 0
        comboLabel.text = "\(combo)"
        
        xMarks.update(num: missCount)
        
        if missCount == maxMiss {
            gameOver()
        }
    }
    
    func bombExplode() {
        
        for case let fruit as Fruit in children {
            fruit.removeFromParent()
            //explode
            particleEffect(position: fruit.position)
        }
        
        explodeOverlay.run(SKAction.sequence([
            SKAction.fadeAlpha(to: 1, duration: 0.2),
            SKAction.fadeAlpha(to: 0, duration: 0.5),
        ]))
        
        //sound
    }
    
    func gameOver() {
        if score > best {
            best = score
            
            //save data
            UserDefaults.standard.set(best, forKey: "best")
            UserDefaults.standard.synchronize()
        }
        
        promptLabel.isHidden = false
        promptLabel.text = "Game Over"
        promptLabel.fontName = "Impact"
        promptLabel.setScale(0)
        promptLabel.run(SKAction.scale(to: 1, duration: 0.3))
        
        gamePhase = .GameOver
        
        fruitThrowTimer.invalidate()
        
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) {_ in self.gamePhase = .Ready}
    }
    
    func particleEffect(position: CGPoint) {
        let emitter = SKEmitterNode(fileNamed: "Explode.sks")
        emitter?.position = position
        addChild(emitter!)
    }
    
    func playSoundEffect(soundFile: String) {
        let audioNode = SKAudioNode(fileNamed: soundFile)
        audioNode.autoplayLooped = false
        addChild(audioNode)
        audioNode.run(SKAction.play())
        audioNode.run(SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.removeFromParent()
        ]))
    }
    
    func pauseGame(isPaused: Bool?) {
        if let paused = isPaused, !paused {
            scene?.view?.isPaused = true
            fruitThrowTimer.invalidate()
            pausedLabel.isHidden = false
        } else {
            pausedLabel.isHidden = true
            fruitThrowTimer = Timer.scheduledTimer(withTimeInterval: score > 50 ? 0.5 : 1.5, repeats: true, block: {_ in self.createFruits()})
            scene?.view?.isPaused = false
        }
    }
}
