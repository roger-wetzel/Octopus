//
//  Octopus.swift
//  Octopus
//
//  Created by Roger on 30/12/15.
//  Copyright © 2015 Roger Wetzel. All rights reserved.
//

import Foundation
import SpriteKit

class Octopus: SKNode {
    let tentacle1a, tentacle1b, tentacle2, tentacle3, tentacle4: Tentacle
    var tentacle1: Tentacle // Is tentacle1a or tentacle1b
    var tick: Int
    var tickTrigger: Int
    var roundRobin: Int
    
    override init() {
        tentacle1a = Tentacle(sprites: ["016", "011", "006"])
        tentacle1b = Tentacle(sprites: ["016", "014", "012", "009"])
        tentacle2 = Tentacle(sprites: ["023", "022", "021", "020", "018"])
        tentacle3 = Tentacle(sprites: ["030", "031", "033", "032"])
        tentacle4 = Tentacle(sprites: ["043", "045", "047"])

        tentacle1 = tentacle1a
        tick = 0
        tickTrigger = 8
        roundRobin = 0
        
        super.init()
    
        self.addChild(tentacle1a)
        self.addChild(tentacle1b)
        self.addChild(tentacle2)
        self.addChild(tentacle3)
        self.addChild(tentacle4)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show() {
        let scene = self.scene as! GameScene
        scene.showSprite("019") // Body
        scene.showSprite("040") // Nose
    }

    func hideTentacles() {
        for tentacle in [tentacle1a, tentacle1b, tentacle2, tentacle3, tentacle4] {
            tentacle.hide()
        }
    }
    
    func reset() {
        self.tick = 0
        self.tentacle1 = tentacle1a
        self.roundRobin = 0
        
        for tentacle in [tentacle1a, tentacle1b, tentacle2, tentacle3, tentacle4] {
            tentacle.reset()
        }
    }
    
    func update() {
        if self.tick % self.tickTrigger == 0 {
            updateTentacles()
            
            self.runAction(SKAction.playSoundFileNamed("tick.mp3", waitForCompletion: false))
        }
        self.tick += 1
    }
    
    func capture() {
        self.tentacle2.forcePosition(2)
        self.tentacle2.update()
        self.tentacle3.forcePosition(2)
        self.tentacle3.update()
    }
    
    func updateTentacles() {
        let tentacles = [tentacle1, tentacle2, tentacle3, tentacle4]
        tentacles[self.roundRobin % tentacles.count].update()
        
        if self.tentacle1.isAtStartingPoint() { // Choose way of first tentacle
            self.tentacle1 = arc4random_uniform(2) == 0 ? self.tentacle1a : self.tentacle1b
        }
        
        self.roundRobin += 1
    }
}
