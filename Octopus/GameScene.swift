//
//  GameScene.swift
//  Octopus
//
//  Created by Roger on 27/12/15.
//  Copyright (c) 2015 Roger Wetzel. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    enum State {
        case Idle // Waiting for user to start game (press Play button on remote to start)
        case Game // Game is running
        case Pause // While game is running, user may press Play/Pause button to pause
    }
    var state: GameScene.State = .Idle
    
    var octopus = Octopus()
    var diver = Diver()
    var score: Int = 0
    var highscore: Int = 0
    var tick: Int = 0
    
    enum IdleAnimationState {
        case LegsRelaxed, LegsSpread
    }
    var idleAnimationState: IdleAnimationState = .LegsRelaxed
    
    let label = SKLabelNode(fontNamed: "-Bold")
    let highscoreLabel = SKLabelNode(fontNamed: "-Bold")
    let spritesRootNode = SKSpriteNode()
    
    override func pressesBegan(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        for item in presses {
            if item.type == .LeftArrow && self.state == .Game {
                self.diver.goLeft()
            }

            if item.type == .RightArrow && self.state == .Game {
                self.diver.goRight()
            }
            
            if item.type == .PlayPause {
                changeState()
            }
        }
    }
    
    override func pressesEnded(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        // Ignored
    }
    
    override func pressesChanged(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        // Ignored
    }
    
    override func pressesCancelled(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        // Ignored
    }
    
    override func didMoveToView(view: SKView) {
        // Setup scene

        // Background
        
        let backgroundImage = SKSpriteNode(imageNamed: "Background")
        backgroundImage.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        backgroundImage.setScale(0.85)
        self.addChild(backgroundImage)
            
        // Score
        
        self.label.fontSize = 32
        self.label.position = CGPoint(x: CGRectGetMidX(self.frame) + 228, y: CGRectGetMidY(self.frame) + 114)
        self.label.fontColor = SKColor.blackColor()
        self.label.colorBlendFactor = 1
        self.label.horizontalAlignmentMode = .Right
        self.addChild(self.label)

        // Highscore
        
        self.highscoreLabel.fontSize = 26
        self.highscoreLabel.position = CGPoint(x: CGRectGetMidX(self.frame) - 182, y: CGRectGetMidY(self.frame) - 137)
        self.highscoreLabel.fontColor = SKColor.blackColor()
        self.highscoreLabel.colorBlendFactor = 1
        self.label.horizontalAlignmentMode = .Right
        self.addChild(self.highscoreLabel)

        if let storedHighscore = NSUserDefaults.standardUserDefaults().objectForKey("highscore") as? Int {
            self.highscore = storedHighscore
        }

        updateScores()
        
        // Sprites
        
        let imageAtlas = UIImage(named: "Octopus")

        if let path = NSBundle.mainBundle().pathForResource("octopus", ofType: "json") {
            do {
                let jsonData = try NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    
                    let sprites = json["sprites"]! as! NSDictionary
                    
                    for sprite in sprites {
                        let key = sprite.key as! String
                        let spriteValue = sprite.value as! NSDictionary
                        
                        let frame = spriteValue.valueForKey("frame") as! NSDictionary
                        let x = frame.valueForKey("x") as! CGFloat
                        let y = frame.valueForKey("y") as! CGFloat
                        let w = frame.valueForKey("w") as! CGFloat
                        let h = frame.valueForKey("h") as! CGFloat
                        
                        let rect = CGRectMake(x, y, w, h)
                        let imageRef = CGImageCreateWithImageInRect(imageAtlas!.CGImage, rect)
                        let image = UIImage(CGImage: imageRef!, scale: 1.0, orientation: UIImageOrientation.Up)

                        let texture = SKTexture(image: image)
                        let sprite = SKSpriteNode(texture: texture)
                        sprite.name = key
                        sprite.anchorPoint = CGPoint(x: 0.0, y: 1.0)
                        sprite.hidden = true // Hide everything
  
                        spritesRootNode.addChild(sprite)
                    }
                } catch {}
            } catch {}
        }

        // Sprite positioning
        
        if let path = NSBundle.mainBundle().pathForResource("data", ofType: "json") {
            do {
                let jsonData = try NSData(contentsOfFile: path, options: NSDataReadingOptions.DataReadingMappedIfSafe)
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as! NSArray
                    
                    for element in json {
                        let name = element.valueForKey("id") as! String
                        let x = element.valueForKey("x") as! Int
                        let y = element.valueForKey("y") as! Int
                        
                        if let sprite = self.spritesRootNode.childNodeWithName(name) {
                            sprite.position = CGPoint(x: x + 200, y: 580 - y)
                        }
                    }
                } catch {}
            } catch {}
        }
    
        // Align sprites with background/device
        
        self.spritesRootNode.setScale(0.72)
        self.spritesRootNode.position = CGPoint(x: 164, y: 110)
        self.addChild(self.spritesRootNode)
        
        // Add octopus and diver to scene graph in order to access them later
        
        self.octopus.name = "octopus"
        self.addChild(self.octopus)
        self.octopus.show()

        self.diver.name = "diver"
        self.addChild(self.diver)
        
        for sprite in ["016", "011", "043", "045", "047"] { // Tentacles for idle animation
            showSprite(sprite)
        }
        
        // Collision detection between diver and tentacles
        
        self.diver.positions[1].fatalTentacle = self.octopus.tentacle1a
        self.diver.positions[2].fatalTentacle = self.octopus.tentacle1b
        self.diver.positions[3].fatalTentacle = self.octopus.tentacle2
        self.diver.positions[4].fatalTentacle = self.octopus.tentacle3
        self.diver.positions[5].fatalTentacle = self.octopus.tentacle4
    }
    
    func showSprite(let sprite: String) {
        if let node = self.spritesRootNode.childNodeWithName(sprite) { // Hint: Serach entire scene with pattern "//name"
            node.hidden = false
        }
    }

    func hideSprite(let sprite: String) {
        if let node = self.spritesRootNode.childNodeWithName(sprite) {
            node.hidden = true
        }
    }

    func changeState() {
        switch self.state {
        case .Idle:
            clearIdleAnimationScreen()
            self.octopus.hideTentacles()
            self.score = 0
            self.octopus.reset()
            self.diver.reset()
            self.state = .Game
            
        case .Game:
            self.state = .Pause
            
        case .Pause:
            self.state = .Game
        }
    }
    
    func updateScores() {
        self.label.text = String(self.score)
        self.highscoreLabel.text = String(self.highscore)
    }
    
    func addPoints(let points: Int) {
        for _ in 0..<points {
            self.score += 1
            
            let score = self.score % 1000
            if score == 200 || score == 500 { // Get lifes back every n200 and n500 points
                self.diver.addLifes()
            }
        }
        
        // More points = faster game
        
        var trigger = 9 // Default speed
        let score = self.score % 100
        if score >= 20 && score <= 49 {
            trigger = 8
        } else if score >= 50 && score <= 79 {
            trigger = 7
        } else if score >= 80 && score <= 99 {
            trigger = 6
        }
        self.diver.animationTickTrigger = trigger
        self.octopus.tickTrigger = trigger - 1
        
        updateScores()
    }
    
    func capture() {
        self.octopus.capture()
    }

    func clearIdleAnimationScreen() {
        for sprite in ["001", "002", "003", "004", "005", "007", "008", "013", "017", "024", "034", "036", "041", "044", "039", "046", "042", "010", "015", "025", "026", "029", "036", "037", "027", "035", "038", "028"] {
            hideSprite(sprite)
        }
    }
    
    func gameOver() {
        self.idleAnimationState = .LegsRelaxed
        self.state = .Idle
        
        // Highscore?
        if self.score >= self.highscore {
            self.highscore = self.score
            updateScores()
            NSUserDefaults.standardUserDefaults().setObject(self.highscore, forKey: "highscore")
            NSUserDefaults.resetStandardUserDefaults()
        }
    }
    
    func idleAnimation() {
        if self.tick >= 40 {
            self.idleAnimationState = self.idleAnimationState == .LegsRelaxed ? .LegsSpread : .LegsRelaxed
            self.tick = 0
        }

        // Tentacles and diver's body
        for sprite in ["023", "022", "030", "031", "025", "026", "029"] {
            showSprite(sprite)
        }
        
        let sprites = self.idleAnimationState == .LegsSpread ? ["035", "038", "028"] : ["036", "037", "027"]
        for sprite in sprites {
            showSprite(sprite)
        }
    }
    
    // Main loop: Called before each frame is rendered
    
    override func update(currentTime: CFTimeInterval) {
        self.tick += 1
        
        #if arch(i386) || arch(x86_64)
            print("Running in simulator")
        #else
            if self.tick % 2 == 0 { // Apple TV 4 runs at 60fps. Slow down everything.
                return
            }
        #endif

        switch self.state {
        case .Idle:
            clearIdleAnimationScreen()
            idleAnimation()
            
        case .Game:
            self.diver.update()
            
            if self.diver.isOctopusPaused() == false {
                self.octopus.update()
            }
            
        case .Pause:
            break
        }
    }
}
