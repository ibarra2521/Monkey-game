//
//  GameScene.swift
//  Monkey
//
//  Created by Nivardo Ibarra on 2/4/16.
//  Copyright (c) 2016 Nivardo Ibarra. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var background: SKNode!
    var upBackground: SKNode!
    var contentPlayer: SKNode!
    var player: SKSpriteNode!
    
    // Animation collision
    var textureWin0: SKTexture = SKTexture(imageNamed: "player")
    var textureWin1: SKTexture = SKTexture(imageNamed: "player_2")
    var textureWin2: SKTexture = SKTexture(imageNamed: "player_3")
    
    // Categories
    let monkeyCategory:UInt32 = 0x1 << 00
    let bananaCategory:UInt32 = 0x1 << 1
    
    var update = 0
    
    var soundBanana: SKAction!
    var soundLoop: SKAction!
    
    var scoreLabel: SKLabelNode!
    var score = 0
    
    override func didMoveToView(view: SKView) {
//        /* Setup your scene here */
//        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
//        myLabel.text = "Hello, World!"
//        myLabel.fontSize = 45
//        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
//        
//        self.addChild(myLabel)
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -2.0)
        physicsWorld.contactDelegate = self
        
//        textureWin0 = SKTexture(imageNamed: "player")
//        textureWin1 = SKTexture(imageNamed: "player2")
//        textureWin2 = SKTexture(imageNamed: "player3")
        
        initBackground()
        initPlayer()
        initBanana()
        initSound()
        initLabel()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//       /* Called when a touch begins */
//        
//        for touch in touches {
//            let location = touch.locationInNode(self)
//            
//            let sprite = SKSpriteNode(imageNamed:"Spaceship")
//            
//            sprite.xScale = 0.5
//            sprite.yScale = 0.5
//            sprite.position = location
//            
//            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
//            
//            sprite.runAction(SKAction.repeatActionForever(action))
//            
//            self.addChild(sprite)
//        }
        
        for touch in touches {
            let location = touch.locationInNode(self)
            let move = SKAction.moveToX(location.x, duration: 0.2)
            player.runAction(move)
            
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
//        /* Called before each frame is rendered */
        update++
    }
    
    func initBackground() {
        let width = UIScreen.mainScreen().bounds.size.width
        let height = UIScreen.mainScreen().bounds.size.height
        
        // down
        let image = SKSpriteNode(imageNamed: "background")
        // Image in center
        image.position = CGPoint(x: width/2, y: height/2)
        image.size = CGSize(width: width, height: height)
        
        background = SKNode()
        // Add to the stage
        addChild(background)
        // Add Image to background
        background.addChild(image)
        
        // Add the conteiner of player
        contentPlayer = SKNode()
        addChild(contentPlayer)
        
        // Up
        let upImage = SKSpriteNode(imageNamed: "upBackground")
        upImage.position = CGPoint(x: width/2, y: height/2)
        upImage.size = CGSize(width: width, height: height)
        
        upBackground = SKNode()
        addChild(upBackground)
        upBackground.addChild(upImage)
    }
    
    func initPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        contentPlayer.addChild(player)
        player.position = CGPoint(x: 100, y: player.size.height/2)
        
        // Create the animation with sprites
        let texture1 = SKTexture(imageNamed: "left")
        let texture2 = SKTexture(imageNamed: "right")
        let texture = [texture1, texture2]
        
        let animate: SKAction = SKAction.animateWithTextures(texture, timePerFrame: 0.2)
        let repeatAnimate: SKAction = SKAction.repeatActionForever(animate)
        player.runAction(repeatAnimate)
        
        // collision 
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.dynamic = false
        
        // Rules
        player.physicsBody?.categoryBitMask = monkeyCategory
        player.physicsBody?.collisionBitMask = bananaCategory
        player.physicsBody?.contactTestBitMask = bananaCategory
    }
    
    func createBanana () -> SKSpriteNode {
        let banana =  SKSpriteNode(imageNamed: "banana")
        let randomX = CGFloat(arc4random_uniform(UInt32(frame.size.width-40)))
        
        banana.position.x = randomX + 20
        banana.position.y = frame.size.height + banana.size.height
        
        banana.physicsBody = SKPhysicsBody(texture: banana.texture!, size: banana.size)
        
        // Rules
        banana.physicsBody?.categoryBitMask = bananaCategory
        banana.physicsBody?.collisionBitMask = monkeyCategory
        banana.physicsBody?.contactTestBitMask = monkeyCategory
        
        return banana
    }
    
    func initBanana () {
        let banana = SKAction.runBlock({ () -> Void in
            let tmpBanana = self.createBanana()
            self.contentPlayer.addChild(tmpBanana)
        })
        
        let bananaWait = SKAction.waitForDuration(2, withRange: 2)
        let bananaSequence = SKAction.sequence([banana, bananaWait])
        let bananaRepeat = SKAction.repeatActionForever(bananaSequence)
        runAction(bananaRepeat)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if update == 0 {
            return
        }
        update = 0
        
        if contact.bodyA.categoryBitMask == bananaCategory {
            contact.bodyA.node?.removeFromParent()
        }
        
        if contact.bodyB.categoryBitMask == bananaCategory {
            contact.bodyB.node?.removeFromParent()
        }
        
        let textures = [textureWin0, textureWin1, textureWin2]
        player.runAction(SKAction.animateWithTextures(textures, timePerFrame: 0.05))
        player.runAction(soundBanana)
        updateScore()
    }
    
    func initSound () {
        soundBanana = SKAction.playSoundFileNamed("WIN.mp3", waitForCompletion: false)
        soundLoop = SKAction.playSoundFileNamed("LOOP.mp3", waitForCompletion: true)
        
        runAction(SKAction.repeatActionForever(soundLoop))
    }
    
    func initLabel() {
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.fontName = "AmericanTypewriter-CondensedBold"
        scoreLabel.fontColor = UIColor.yellowColor()
        scoreLabel.fontSize = 36
        scoreLabel.position = CGPoint(x: frame.width/2, y: frame.height - 40)
        scoreLabel.zPosition = 10
        addChild(scoreLabel)
    }
    
    func updateScore() {
        score++
        scoreLabel.text = "Score: \(score)"
    }
    
}
