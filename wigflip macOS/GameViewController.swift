//
//  GameViewController.swift
//  wigflip macOS
//
//  Created by James B Harris on 7/8/20.
//

import Cocoa
import SpriteKit
import GameKit
import GameplayKit

// load sounds
let audioPonderosa = SKAction.playSoundFileNamed("ponderosa.m4a", waitForCompletion: false)
let audioSunset = SKAction.playSoundFileNamed("sunset.m4a", waitForCompletion: false)
let audioEgg = SKAction.playSoundFileNamed("egg.m4a", waitForCompletion: false)
let audioScore = SKAction.playSoundFileNamed("score.m4a", waitForCompletion: false)
let audioClick = SKAction.playSoundFileNamed("click.m4a", waitForCompletion: false)
let audioSplat = SKAction.playSoundFileNamed("splat.m4a", waitForCompletion: false)

var gameKitEnabled = Bool()
var gameKitDefaultLeaderboard = String()
var viewController = GameViewController()

class GameViewController: NSViewController, GKGameCenterControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Call the GC authentication controller
        gameKitDefaultLeaderboard = "wigflip_001"
        authenticateLocalPlayer()

        let scene = GameScene.newGameScene()
        scene.scaleMode = .aspectFill

        // Present the scene
        let skView = self.view as! SKView
        viewController = self
        skView.presentScene(scene)
        
        skView.ignoresSiblingOrder = true
        skView.showsFPS = false
        skView.showsNodeCount = false
    }

    // gamecenter functions
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        if GKLocalPlayer.local.isAuthenticated {
            gameKitEnabled = true
            GKAccessPoint.shared.location = .topLeading
            GKAccessPoint.shared.showHighlights = true
            GKAccessPoint.shared.isActive = true
        } else {
            gameKitEnabled = false
            GKAccessPoint.shared.isActive = false
        }
    }
    
    func authenticateLocalPlayer() {
        GKLocalPlayer.local.authenticateHandler = { gcAuthVC, error in
           if GKLocalPlayer.local.isAuthenticated {
             print("Authenticated to Game Center!")
            gameKitEnabled = true
            GKAccessPoint.shared.location = .topLeading
            GKAccessPoint.shared.showHighlights = true
            GKAccessPoint.shared.isActive = true
           } else if let vc = gcAuthVC {
            viewController.present(vc, animator: true as! NSViewControllerPresentationAnimator)
           }
           else {
            gameKitEnabled = false
             print("Error authentication to GameCenter: " +
               "\(error?.localizedDescription ?? "none")")
           }
        }
    }
}

