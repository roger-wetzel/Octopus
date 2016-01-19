//
//  Diver.swift
//  Octopus
//
//  Created by Roger on 31/12/15.
//  Copyright © 2015 Roger Wetzel. All rights reserved.
//

import Foundation
import SpriteKit

class Diver: SKNode {
    
    class Animation {
        var positionIndex: Int
        var positions: [Position]
        var tick: Int
        var tickTrigger: Int
        var onCompletion: () -> ()
        
        init(diver: Diver, tickTrigger: Int, onCompletion: () -> () = {}) {
            self.positions = []
            self.positionIndex = 0
            self.tick = 0
            self.tickTrigger = tickTrigger
            self.onCompletion = onCompletion
        }

        func isInterruptible() -> Bool {
            return true
        }

        func isPausingOctopus() -> Bool {
            return false
        }
        
        func hasCompleted() -> Bool {
            return self.positionIndex == self.positions.count
        }
        
        func run(diver: Diver) {
            let position = self.positions[self.positionIndex]
            
            if self.tick == 0 {
                for action in position.actions {
                    action()
                }
            }

            diver.showSpritesAtPosition(position)
            
            if self.tick == self.tickTrigger {
                self.tick = 0
                self.positionIndex += 1
                if self.positionIndex == self.positions.count {
                    self.onCompletion()
                }
            } else {
                self.tick += 1
            }
        }
    }
    
    class TakeTreasureAnimation: Animation {
        override init(diver: Diver, tickTrigger: Int, onCompletion: () -> () = {}) {
            super.init(diver: diver, tickTrigger: tickTrigger, onCompletion: onCompletion)
    
            let take0 = Position()
            take0.withoutBagSprites = ["041", "046"]
            take0.withBagSprites = ["041", "046", "039"]
            self.positions.append(take0)
        
            let take1 = Position()
            take1.withoutBagSprites = ["041", "044"]
            take1.withBagSprites = ["041", "044", "039"]
            self.positions.append(take1)
        
            let take2 = Position()
            take2.withoutBagSprites = [] // At this point/position the diver has a bag
            take2.withBagSprites = ["041", "042", "039"]
            take2.actions = [diver.putTreasureInBag]
            self.positions.append(take2)
        }
    }

    class StoreTreasureAnimation: Animation {
        override init(diver: Diver, tickTrigger: Int, onCompletion: () -> () = {}) {
            super.init(diver: diver, tickTrigger: tickTrigger, onCompletion: onCompletion)
        
            let storeArmUp = Position()
            storeArmUp.withoutBagSprites = ["002", "004"]
            storeArmUp.withBagSprites = [] // At this point/position the diver does not have a bag
            
            let storeArmDown = Position()
            storeArmDown.withoutBagSprites = ["002", "005"]
            storeArmDown.withBagSprites = [] // At this point/position the diver does not have a bag
            
            self.positions.append(storeArmUp)
            self.positions.append(storeArmDown)
            self.positions.append(storeArmUp)
        }
    }
    
    class PlayShortBeepAnimation: Animation {
        init(diver: Diver, tickTrigger: Int, times: Int, onCompletion: () -> () = {}) {
            super.init(diver: diver, tickTrigger: tickTrigger, onCompletion: onCompletion)
            
            let sound = Position()
            sound.actions = [{ diver.playShortBeep() }]
            
            for _ in 0..<times {
                self.positions.append(sound)
            }
        }
        
        override func isInterruptible() -> Bool {
            return false
        }
        
        override func isPausingOctopus() -> Bool {
            return true
        }
    }
    
    class CaughtAnimation: Animation {
        override init(diver: Diver, tickTrigger: Int, onCompletion: () -> () = {}) {
            super.init(diver: diver, tickTrigger: tickTrigger, onCompletion: onCompletion)
            
            // Note: We need to know the current position of the diver otherwise diver won't be shown
        
            var diverPosition = diver.positions[diver.positionIndex]
            let animations = diver.animations.filter { $0 is TakeTreasureAnimation }
            for animation in animations {
                diverPosition = animation.positions[animation.positionIndex] // TODO something's wrong here
            }
            let caught0 = Position()
            caught0.withoutBagSprites = diverPosition.withoutBagSprites
            caught0.withBagSprites = diverPosition.withBagSprites
            self.positions.append(caught0)
            self.positions.append(caught0) // Show this twice/longer
            
            let caughtNoDiverVisible = Position()
            caughtNoDiverVisible.withoutBagSprites = []
            caughtNoDiverVisible.withBagSprites = []
            caughtNoDiverVisible.actions = [diver.playShortBeep]
            self.positions.append(caughtNoDiverVisible)
            
            let capturedSpritesLegsRelaxed = ["025", "026", "029", "036", "037", "027"]
            let capturedSpritesLegsSpread = ["025", "026", "029", "035", "038", "028"]
            
            let caught1 = Position()
            caught1.withoutBagSprites = capturedSpritesLegsRelaxed
            caught1.withBagSprites = capturedSpritesLegsRelaxed
            caught1.actions = [diver.playShortBeep, diver.caughtAction]
            self.positions.append(caught1)
            
            let caughtLegsSpread = Position()
            caughtLegsSpread.withoutBagSprites = capturedSpritesLegsSpread
            caughtLegsSpread.withBagSprites = capturedSpritesLegsSpread
            caughtLegsSpread.actions = [diver.playShortBeep]
            
            let caughtLegsRelaxed = Position()
            caughtLegsRelaxed.withoutBagSprites = capturedSpritesLegsRelaxed
            caughtLegsRelaxed.withBagSprites = capturedSpritesLegsRelaxed
            caughtLegsRelaxed.actions = [diver.playShortBeep]
            
            for _ in 0..<3 {
                self.positions.append(caughtLegsSpread)
                self.positions.append(caughtLegsRelaxed)
            }
        }

        override func isInterruptible() -> Bool {
            return false
        }
    }

    class TwoLifesAnimation: Animation {
        override init(diver: Diver, tickTrigger: Int, onCompletion: () -> () = {}) {
            super.init(diver: diver, tickTrigger: tickTrigger, onCompletion: onCompletion)
            
            let position0 = Position()
            position0.withBagSprites = ["010", "015"]
            position0.withoutBagSprites = ["010", "015"]
            self.positions.append(position0)
            
            let position1 = Position()
            position1.withBagSprites = ["002", "005", "015"]
            position1.withoutBagSprites = ["002", "005", "015"]
            self.positions.append(position1)
            
            let position2 = Position()
            position2.withBagSprites = ["002", "005", "010"]
            position2.withoutBagSprites = ["002", "005", "010"]
            self.positions.append(position2)
        }

        override func isInterruptible() -> Bool {
            return true
        }
    }
    
    class OneLifeAnimation: Animation {
        override init(diver: Diver, tickTrigger: Int, onCompletion: () -> () = {}) {
            super.init(diver: diver, tickTrigger: tickTrigger, onCompletion: onCompletion)
            
            let position0 = Position()
            position0.withBagSprites = ["010"]
            position0.withoutBagSprites = ["010"]
            self.positions.append(position0)
            
            let position1 = Position()
            position1.withBagSprites = ["002", "005"]
            position1.withoutBagSprites = ["002", "005"]
            self.positions.append(position1)
            
            let position2 = Position()
            position2.withBagSprites = ["002", "005"]
            position2.withoutBagSprites = ["002", "005"]
            self.positions.append(position2)
        }
        
        override func isInterruptible() -> Bool {
            return true
        }
    }

    class OneLifeUpAnimation: Animation {
        override init(diver: Diver, tickTrigger: Int, onCompletion: () -> () = {}) {
            super.init(diver: diver, tickTrigger: tickTrigger, onCompletion: onCompletion)
            
            let position0 = Position()
            position0.withBagSprites = ["010"]
            position0.withoutBagSprites = ["010"]
            position0.actions = [diver.playBeep]
            
            let position1 = Position()
            position1.withBagSprites = ["010", "015"]
            position1.withoutBagSprites = ["010", "015"]
            position1.actions = [diver.playBeep]

            for _ in 0..<5 {
                self.positions.append(position0)
                self.positions.append(position1)
            }
        }
    }

    class TwoLifesUpAnimation: Animation {
        override init(diver: Diver, tickTrigger: Int, onCompletion: () -> () = {}) {
            super.init(diver: diver, tickTrigger: tickTrigger, onCompletion: onCompletion)
            
            let position0 = Position()
            position0.withBagSprites = []
            position0.withoutBagSprites = []
            position0.actions = [diver.playBeep]
            
            let position1 = Position()
            position1.withBagSprites = ["010", "015"]
            position1.withoutBagSprites = ["010", "015"]
            position1.actions = [diver.playBeep]
            
            for _ in 0..<5 {
                self.positions.append(position0)
                self.positions.append(position1)
            }
        }
    }
    
    class Position {
        var withoutBagSprites: [String] = []
        var withBagSprites: [String] = []
        var fatalTentacle: Tentacle? = nil
        
        var actions: [() -> Void] = []
        var isAllowedToGoLeft: () -> Bool = { () -> Bool in return true }
    }

    // Diver
    
    var positionIndex: Int = 0
    var positions: [Position] = []
    var isCarryingTreasure: Bool = false
    var isCaught: Bool = false
    var gameOver: Bool = false
    var animations: [Animation] = []
    var gameBlockingAnimations: [Animation] = []
    var animationTickTrigger: Int = 9
    var lifes: Int = 3
    
    override init() {
        super.init()
        
        let position0 = Position()
        position0.withoutBagSprites = ["002", "005"]
        position0.withBagSprites = ["002", "004"]
        position0.actions = [storeTreasure]
        self.positions.append(position0)
        
        let position1 = Position()
        position1.withoutBagSprites = ["001"]
        position1.withBagSprites = ["001", "008"]
        position1.isAllowedToGoLeft = { () -> Bool in return self.isCarryingTreasure } // Diver is not allowed to return to boat without treasure
        self.positions.append(position1)
        
        let position2 = Position()
        position2.withoutBagSprites = ["003"]
        position2.withBagSprites = ["003", "007"]
        self.positions.append(position2)
        
        let position3 = Position()
        position3.withoutBagSprites = ["013"]
        position3.withBagSprites = ["013", "017"]
        self.positions.append(position3)

        let position4 = Position()
        position4.withoutBagSprites = ["024"]
        position4.withBagSprites = ["024", "034"]
        self.positions.append(position4)

        let position5 = Position()
        position5.withoutBagSprites = ["041", "044"]
        position5.withBagSprites = ["041", "044", "039"]
        self.positions.append(position5)
    }

    func reset() {
        self.positionIndex = 0
        self.isCarryingTreasure = false
        self.isCaught = false
        self.gameOver = false
        self.animationTickTrigger = 9
        self.lifes = 3
    }
    
    func playBeep() {
        self.runAction(SKAction.playSoundFileNamed("beep.mp3", waitForCompletion: false))
    }
    
    func playShortBeep() {
        self.runAction(SKAction.playSoundFileNamed("beep_short.mp3", waitForCompletion: false))
    }
    
    func backToBoat() {
        if self.lifes == 0 {
            let scene = self.scene as! GameScene
            scene.gameOver()
            self.gameOver = true
        } else {
            self.positionIndex = 0
            self.isCaught = false
        }
    }
    
    func putTreasureInBag() {
        self.isCarryingTreasure = true
        
        let scene = self.scene as! GameScene
        scene.addPoints(1)
        playShortBeep()
    }
    
    func caughtAction() {
        self.isCarryingTreasure = false

        let scene = self.scene as! GameScene
        scene.capture() // Put octopus in capturing position
    }
    
    func storeTreasure() {
        if self.isCarryingTreasure { // Did diver came back to boat carrying treasure?
            self.isCarryingTreasure = false

            self.animations.append(StoreTreasureAnimation(diver: self, tickTrigger: self.animationTickTrigger - 1))
            self.animations.append(PlayShortBeepAnimation(diver: self, tickTrigger: self.animationTickTrigger - 1, times: 3))
            
            let scene = self.scene as! GameScene
            scene.addPoints(3)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showSpritesAtPosition(let currentPosition: Diver.Position) {
        let scene = self.scene as! GameScene
        if isCarryingTreasure {
            for sprite in currentPosition.withBagSprites {
                scene.showSprite(sprite)
            }
        } else {
            for sprite in currentPosition.withoutBagSprites {
                scene.showSprite(sprite)
            }
        }
    }
    
    func goLeft() {
        if self.positionIndex == 0 {
            return
        }
        
        if self.isCaught {
            return
        }
        
        if self.positions[positionIndex].isAllowedToGoLeft() {
            self.animations = self.animations.filter { $0.isInterruptible() == false }
            self.positionIndex -= 1
        }
    }
    
    func goRight() {
        if self.isCaught {
            return
        }

        self.animations = self.animations.filter { $0.isInterruptible() == false || $0 is TakeTreasureAnimation }
        
        if self.positionIndex == self.positions.count - 1 { // Is driver at treasure position?
            if (self.animations.filter { $0 is TakeTreasureAnimation }).count == 0 {
                self.animations.append(TakeTreasureAnimation(diver: self, tickTrigger: self.animationTickTrigger - 4))
            }
            
            return
        }

        self.positionIndex += 1
    }
    
    func showLifes() {
        let scene = self.scene as! GameScene
        
        if self.lifes == 3 {
            scene.showSprite("010")
            scene.showSprite("015")
        } else if self.lifes == 2 {
            scene.showSprite("010")
        }
    }
    
    func isOctopusPaused() -> Bool {
        let animations = self.animations.filter { $0.isPausingOctopus() == true }
        return animations.count > 0 || self.gameBlockingAnimations.count > 0 || isCaught
    }
    
    func addLifes() {
        switch self.lifes {
        case 2:
            self.gameBlockingAnimations.append(OneLifeUpAnimation(diver: self, tickTrigger: self.animationTickTrigger + 6))

        case 1:
            self.gameBlockingAnimations.append(TwoLifesUpAnimation(diver: self, tickTrigger: self.animationTickTrigger + 6))
            
        default:
            break
        }
        
        self.lifes = 3
    }
    
    func clearScreen() {
        let scene = self.scene as! GameScene

        for sprite in ["001", "002", "003", "004", "005", "007", "008", "013", "017", "024", "025", "026", "027", "028", "029", "034", "035", "036", "037", "038", "041", "044", "039", "046", "042", "010", "015"] {
            scene.hideSprite(sprite)
        }
    }
    
    func update() {
        if self.gameBlockingAnimations.count > 0 {
            let scene = self.scene as! GameScene
            scene.hideSprite("010")
            scene.hideSprite("015")
            
            var remainingAnimations: [Animation] = []
            for animation in self.gameBlockingAnimations {
                animation.run(self)
                if animation.hasCompleted() == false {
                    remainingAnimations.append(animation)
                }
            }
            self.gameBlockingAnimations = remainingAnimations
            
            return // Block game
        }
        
        clearScreen()
        
        if self.animations.count > 0 {
            var remainingAnimations: [Animation] = []
            for animation in self.animations {
                animation.run(self)
                if animation.hasCompleted() == false {
                    remainingAnimations.append(animation)
                }
            }
            self.animations = remainingAnimations
        }
        
        if self.gameOver { // Final CaughtAnimation might have ended: Game over
            return
        }
        
        let position = self.positions[positionIndex]
        
        if self.isCaught == false {
            self.showLifes()
            
            if position.fatalTentacle?.isFatal == true { // Caught?
                self.isCaught = true
                self.lifes -= 1

                let animations = self.animations.filter { $0 is TakeTreasureAnimation }
                if animations.count == 0 {
                    self.showSpritesAtPosition(position)
                }
                
                // We can overwrite (cancel) all animations
                self.animations = [CaughtAnimation(diver: self, tickTrigger: self.animationTickTrigger, onCompletion: self.backToBoat)]

                if self.lifes == 2 {
                    self.animations.append(TwoLifesAnimation(diver: self, tickTrigger: self.animationTickTrigger * 4))
                } else if self.lifes == 1 {
                    self.animations.append(OneLifeAnimation(diver: self, tickTrigger: self.animationTickTrigger * 4))
                }

                self.playBeep()
            }
        }
        
        let animationsThatShowDiver = self.animations.filter { $0 is StoreTreasureAnimation || $0 is TakeTreasureAnimation
        || $0 is CaughtAnimation }
        if animationsThatShowDiver.count == 0 {
            for action in position.actions {
                action()
            }
            self.showSpritesAtPosition(position)
        }
    }
}
