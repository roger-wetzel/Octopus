//
//  Tentacle.swift
//  Octopus
//
//  Created by Roger on 30/12/15.
//  Copyright © 2015 Roger Wetzel. All rights reserved.
//

import Foundation
import SpriteKit

class Tentacle: SKNode {
    
    enum State {
        case Idle, Forth, Back
    }
    
    let sprites: [String]
    var state: State = .Idle
    var delay: Int = 0
    var spriteIndex: Int = 0
    var isFatal: Bool = false
    
    init(sprites: [String]) {
        self.sprites = sprites
        super.init()
        initDelay()
    }
    
    func reset() {
        self.state = .Idle
        self.spriteIndex = 0
        self.isFatal = false
        initDelay()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initDelay() {
        delay = Int(arc4random_uniform(3))
    }
    
    func isAtStartingPoint() -> Bool {
        return state == .Idle && delay == 0
    }

    func forcePosition(index: Int) {
        spriteIndex = index
        if state == .Idle {
            state = .Forth
        }
    }

    func hide() {
        let scene = self.scene as! GameScene

        for sprite in sprites {
            scene.hideSprite(sprite)
        }
    }
    
    func update() {
        let scene = self.scene as! GameScene
        
        hide()
        
        if state == .Idle {
            if delay == 0 {
                state = .Forth
            }
            else {
                delay -= 1
            }
        }
        
        if state != .Idle {
            for index in 0..<spriteIndex {
                scene.showSprite(sprites[index])
            }
            self.isFatal = spriteIndex  == sprites.count
            
            if state == .Forth {
                spriteIndex += 1
                if spriteIndex == sprites.count {
                    state = .Back
                }
            } else if state == .Back {
                spriteIndex -= 1
                if spriteIndex == 0 {
                    state = .Idle
                    initDelay()
                }
            }
        }
    }
}
