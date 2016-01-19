//
//  GameViewController.swift
//  Octopus
//
//  Created by Roger on 27/12/15.
//  Copyright (c) 2015 Roger Wetzel. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    var gameScene: GameScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let scene = GameScene(fileNamed: "GameScene") {
            self.gameScene = scene
            
            // Configure the view
            let skView = self.view as! SKView
//            skView.showsFPS = true
//            skView.showsNodeCount = true
            
            /* true: Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = false
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use
    }
    
    override func pressesBegan(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        gameScene?.pressesBegan(presses, withEvent: event)
    }
    
    override func pressesEnded(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        gameScene?.pressesEnded(presses, withEvent: event)
    }
}
