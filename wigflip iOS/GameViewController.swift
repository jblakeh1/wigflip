//Copyright (c) 2022 J. Blake Harris hello@motorcycl3.com
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.

import UIKit
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

class GameViewController: UIViewController, GKGameCenterControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Call the GC authentication controller
        gameKitDefaultLeaderboard = "leaderboard_name"

        authenticateLocalPlayer()

        let scene = GameScene.newGameScene()
        scene.scaleMode = .aspectFill
        if UIDevice.current.userInterfaceIdiom == .pad {
            scene.size = CGSize(width: 1539, height: 1539)
        }

        // Present the scene
        let skView = self.view as! SKView
        viewController = self
        skView.presentScene(scene)
        skView.ignoresSiblingOrder = true
        skView.showsFPS = false
        skView.showsNodeCount = false
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
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
            viewController.present(vc, animated: true)
           }
           else {
            gameKitEnabled = false
             print("Error authentication to GameCenter: " +
               "\(error?.localizedDescription ?? "none")")
           }
        }
    }
}
