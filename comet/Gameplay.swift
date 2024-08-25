//
//  Gameplay.swift
//  comet
//
//  Created by Maya Lekhi on 2024-08-21.
//

import SpriteKit

typealias HomeButtonCallback = () -> Void

struct PhysicsCategory {
    static let dog: UInt32 = 0x1 << 0
    static let shrub: UInt32 = 0x1 << 1
    static let ground: UInt32 = 0x1 << 2
}

class Gameplay: SKScene, SKPhysicsContactDelegate {
    
    
    private var dog: SKSpriteNode!
    private var levelLabel: SKLabelNode!
    private var gameOverLabel: SKSpriteNode!
    private var replayButton: SKSpriteNode!
    private var level = 0
    private var gameOver = false
    private var pressCount = 0
    private var shrubsRemoved = 0
    private var shrubsToSpawn = 10
    private var tutorialPopup: SKSpriteNode?
    private var closeButton: SKSpriteNode?
    var homeButtonCallback: HomeButtonCallback?

    
    override func didMove(to view: SKView) {
        if let savedLevel = UserDefaults.standard.value(forKey: "savedLevel") as? Int {
            level = savedLevel
        } else {
            level = 0
        }
        
        if level == 0 {
            showTutorialPopup()
        }
        setupScene()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if contactMask == (PhysicsCategory.dog | PhysicsCategory.shrub) {
            print("Collision detected!")
            showGameOverScreen()
        }
    }
    
    private func setupScene() {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        background.size = self.size
        background.zPosition = -1
        addChild(background)
        
        setupGround()
        setupDog()
        setupLevelLabel()
        startLevel()
        physicsWorld.contactDelegate = self
    }
    
    private func setupDog() {
        dog = SKSpriteNode(imageNamed: "dog")
        dog.size = CGSize(width: 60, height: 60)
        dog.position = CGPoint(x: frame.midX - 100, y: 50)
        dog.physicsBody = SKPhysicsBody(rectangleOf: dog.size)
        configurePhysicsBody(dog.physicsBody, category: PhysicsCategory.dog)
        addChild(dog)
    }
    
    private func setupLevelLabel() {
        levelLabel = SKLabelNode(text: "Level 0")
        levelLabel.fontName = "Daydream"
        levelLabel.fontSize = 18
        levelLabel.fontColor = .white
        levelLabel.position = CGPoint(x: 75, y: frame.size.height - 50)
        addChild(levelLabel)
    }
    
    private func setupGround() {
        let ground = SKSpriteNode(color: SKColor(red: 184/255.0, green: 185/255.0, blue: 236/255.0, alpha: 1.0), size: CGSize(width: frame.size.width, height: 50))
        ground.position = CGPoint(x: frame.midX, y: ground.size.height / 2)
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = PhysicsCategory.ground
        addChild(ground)
    }
    
    private func startLevel() {
        shrubsRemoved = 0
        spawnShrubsPeriodically()
    }
    
    private func spawnShrubsPeriodically() {
        let shrubSpawnInterval: TimeInterval = max(1.0, 3.0 - Double(level) * 0.5) // Decrease spawn interval as level increases
        run(SKAction.repeatForever(SKAction.sequence([
            SKAction.run { self.spawnShrubs() },
            SKAction.wait(forDuration: shrubSpawnInterval)
        ])))
    }
    
    private func spawnShrubs() {
        guard !gameOver else { return }
        
        let shrubSize = CGSize(width: 60, height: 60)
        let shrub = SKSpriteNode(imageNamed: "shrub")
        shrub.size = shrubSize
        shrub.position = CGPoint(x: frame.size.width + shrubSize.width / 2, y: 50)
        shrub.physicsBody = SKPhysicsBody(rectangleOf: shrubSize)
        configurePhysicsBody(shrub.physicsBody, category: PhysicsCategory.shrub)
        shrub.name = "shrub"
        addChild(shrub)
        
        let moveSpeed = max(2.0, 4.0 - Double(level) * 0.5) // Increase speed with level
        let moveAction = SKAction.moveBy(x: -frame.size.width - shrubSize.width, y: 0, duration: moveSpeed)
        let removeAction = SKAction.removeFromParent()
        shrub.run(SKAction.sequence([moveAction, removeAction]))
    }
    
    override func update(_ currentTime: TimeInterval) {
        if self.shrubsRemoved >= self.shrubsToSpawn {
            self.levelUp()
        }
        
    }
    
    private func saveLevel() {
        UserDefaults.standard.set(level, forKey: "savedLevel")
    }
    
    private func levelUp() {
        level += 1
        levelLabel.text = "Level \(level)"
        
        saveLevel()
        
        sendDogSprite()
        // Pause the game
        isPaused = true
        
        // Create and configure the background image
        let backgroundImage = SKSpriteNode(imageNamed: "banner-short")
        backgroundImage.position = CGPoint(x: frame.midX, y: frame.midY)
        backgroundImage.size = CGSize(width: frame.size.width, height: 250)
        backgroundImage.zPosition = 0
        addChild(backgroundImage)
        
        // Create and configure the level-up image
        let levelUpImage = SKSpriteNode(imageNamed: "level-up")
        levelUpImage.position = CGPoint(x: frame.midX, y: frame.midY)
        levelUpImage.size = CGSize(width: 300, height: 150)
        levelUpImage.zPosition = 1
        addChild(levelUpImage)
        
        let waitAction = SKAction.wait(forDuration: 2.0)
        //        let removeBackgroundAction = SKAction.run {
        //            print("Removing background image")
        //            backgroundImage.removeFromParent()
        //        }
        //        let removeLevelUpAction = SKAction.run {
        //            print("Removing level-up image")
        //            levelUpImage.removeFromParent()
        //        }
        //        let unpauseAction = SKAction.run {
        //            print("Unpausing game")
        //            self.isPaused = false
        //            self.startLevel()
        //        }
        //
        //        let sequence = SKAction.sequence([waitAction, removeBackgroundAction, removeLevelUpAction, unpauseAction])
        
        print("trying to run sequence")
        self.run(waitAction)
    }
    
    private func sendDogSprite() {
        let dogSprite = SKSpriteNode(imageNamed: "dog-gf")
        dogSprite.position = CGPoint(x: -dogSprite.size.width / 2, y: frame.midY)
        dogSprite.zPosition = 2
        addChild(dogSprite)
        
        // Configure physics body for collision detection
        dogSprite.physicsBody = SKPhysicsBody(rectangleOf: dogSprite.size)
        dogSprite.physicsBody?.collisionBitMask = 0
        dogSprite.physicsBody?.affectedByGravity = false
        dogSprite.physicsBody?.isDynamic = true
        
        // Define the movement action
        let moveAction = SKAction.moveTo(x: frame.size.width + dogSprite.size.width / 2, duration: 4.0)
        let removeAction = SKAction.removeFromParent()
        
        // Run the sequence of actions (move and remove)
        let sequence = SKAction.sequence([moveAction, removeAction])
        dogSprite.run(sequence)
    }
    
    private func showGameOverScreen() {
        if !gameOver {
            gameOver = true
            isPaused = true  // Pause the scene
            
            // Create and display the background image
            let backgroundImage = SKSpriteNode(imageNamed: "banner") // Replace with your background image name
            backgroundImage.position = CGPoint(x: frame.midX, y: frame.midY + 35)
            backgroundImage.size = CGSize(width: frame.size.width, height: 250)
            backgroundImage.zPosition = 0  // Ensure it's behind all other elements
            addChild(backgroundImage)
            
            // Create and display the game over image
            gameOverLabel = SKSpriteNode(imageNamed: "gameover")
            gameOverLabel.size = CGSize(width: 200, height: 100)
            gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY + 50)
            gameOverLabel.zPosition = 1  // Ensure it's above the background
            addChild(gameOverLabel)
            
            // Create and display the replay button
            replayButton = SKSpriteNode(imageNamed: "restart")
            replayButton.size = CGSize(width: 30, height: 30) // Adjust size if needed
            replayButton.position = CGPoint(x: frame.midX + 75, y: frame.midY - 30) // Positioned to the right
            replayButton.name = "replayButton"
            replayButton.zPosition = 2  // Ensure it's above the background and game over image
            addChild(replayButton)
            
            // Create and display the home button
            let homeButton = SKSpriteNode(imageNamed: "home")
            homeButton.size = CGSize(width: 30, height: 30) // Adjust size if needed
            homeButton.position = CGPoint(x: frame.midX - 75, y: frame.midY - 30) // Positioned to the left
            homeButton.name = "homeButton"
            homeButton.zPosition = 2  // Ensure it's above the background and game over image
            addChild(homeButton)
        }
    }
   
    private func showTutorialPopup() {
        isPaused = true  // Pause the game while the tutorial is displayed
        
        // Create and display the tutorial background
        let tutorialBackground = SKSpriteNode(imageNamed: "banner")
        tutorialBackground.size = CGSize(width: frame.size.width - 50, height: 600)
        tutorialBackground.position = CGPoint(x: frame.midX, y: frame.midY)
        tutorialBackground.zPosition = 10  // Ensure it's above everything else
        tutorialBackground.name = "tutorialPopup"
        addChild(tutorialBackground)
        self.tutorialPopup = tutorialBackground
        
        // Tutorial text
        let tutorialTexts = [
            "Get Comet to his girlfriend!",
            "Tap to yap!",
            "Avoid the obstacles.",
            "3 barks clear an obstacle."
        ]
        
        // Constants for text positioning
        let fontSize: CGFloat = 18
        let verticalSpacing: CGFloat = 60
        
        for (index, text) in tutorialTexts.enumerated() {
            let label = SKLabelNode(text: text)
            label.fontName = "Daydream"
            label.fontSize = fontSize
            label.fontColor = .white
            label.position = CGPoint(x: 0, y: CGFloat(100 - index * Int(verticalSpacing)))
            label.zPosition = 11
            tutorialBackground.addChild(label)
        }
        
        // Add close button ("X") at an absolute position
        closeButton = SKSpriteNode(imageNamed: "x-mark")
        closeButton?.size = CGSize(width: 30, height: 30)
        
        // Position the close button at an absolute position on the screen
        let closeButtonPosition = CGPoint(x: frame.size.width - 50 - 15, y: frame.size.height - 50 - 15)  // Adjust coordinates as needed
        closeButton?.position = closeButtonPosition
        
        closeButton?.zPosition = 11
        closeButton?.name = "closeButton"
        addChild(closeButton!)
    }

    private func closeTutorialPopup() {
        // Remove the tutorial popup
        if let tutorialPopup = self.tutorialPopup {
            tutorialPopup.removeFromParent()
            self.tutorialPopup = nil
        }
        if let closeButton = self.closeButton {
            closeButton.removeFromParent()
            self.closeButton = nil
        }

        isPaused = false  // Resume the game
        saveLevel()  // Save the level when closing the tutorial popup
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchLocation = touches.first?.location(in: self) else { return }

        if gameOver {
            // Handle game over scenarios
            if replayButton.contains(touchLocation) {
                resetGame()
            } else if let homeButton = childNode(withName: "homeButton"), homeButton.contains(touchLocation) {
                // Call the home button callback if it exists
                homeButtonCallback?()
            }
        } else if let closeButton = closeButton, closeButton.contains(touchLocation) {
            closeTutorialPopup()
        } else {
            // Change the dog's image to "dog_bark" briefly
            dog.texture = SKTexture(imageNamed: "dog-bark")
            
            // Revert to the original image after a short delay
            let revertAction = SKAction.run {
                self.dog.texture = SKTexture(imageNamed: "dog")
            }
            let waitAction = SKAction.wait(forDuration: 0.2) // Adjust duration as needed
            let sequence = SKAction.sequence([waitAction, revertAction])
            dog.run(sequence)
            
            pressCount += 1
            if pressCount == 3 {
                removeFirstShrub()
                pressCount = 0
            }
        }
    }

    private func resetGame() {
        // Unpause the scene
        isPaused = false
        
        // Remove all nodes and reset variables
        removeAllChildren()
        setupScene()
        
        // Reset game-related variables
        level = 0
        levelLabel.text = "Level 0"
        gameOver = false
        pressCount = 0
        shrubsToSpawn = 30
    }

    private func removeFirstShrub() {
        enumerateChildNodes(withName: "shrub") { node, _ in
            if let shrub = node as? SKSpriteNode {
                shrub.removeFromParent()
                print("shrub killed")
                self.shrubsRemoved += 1
                print("removed \(self.shrubsRemoved)")
                return
            }
        }
    }
    
    private func configurePhysicsBody(_ body: SKPhysicsBody?, category: UInt32) {
        body?.categoryBitMask = category
        body?.contactTestBitMask = PhysicsCategory.dog | PhysicsCategory.shrub
        body?.collisionBitMask = PhysicsCategory.ground | PhysicsCategory.shrub
        body?.affectedByGravity = false
        body?.isDynamic = true
        body?.linearDamping = 0
        body?.angularDamping = 0
        body?.friction = 0
        body?.restitution = 0
    }
}
