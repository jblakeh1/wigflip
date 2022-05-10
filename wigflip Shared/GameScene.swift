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

import SpriteKit

class GameScene: SKScene {
    var startButton = SKNode()
    var egg = SKNode()
    var resetButton = SKNode()
    var launchTextures = [SKTexture]()
    var startTextures = [SKTexture]()

    let tree = Tree()

    class func newGameScene() -> GameScene {
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
        return scene
    }
        
    func setUpScene() {
        self.run(audioClick)
        if atlasPreload("intro") == true {
            let atlas = SKTextureAtlas(named: "intro")
            for index in 0...17 {
                launchTextures.append(atlas.textureNamed("dottedLine-" + String(index)))
                startTextures.append(atlas.textureNamed("dottedLine-" + String(index)))
            }
            startTextures.reverse()
        }
        let launchAnimation = SKAction.animate(with: launchTextures, timePerFrame: 0.125)
        startButton = self.childNode(withName: "Start")!
        egg = startButton.childNode(withName: "Egg")!
        resetButton = self.childNode(withName: "Reset")!
        egg.run(SKAction.fadeIn(withDuration: 2.0))
        startButton.run(launchAnimation, completion: {
            self.runScene()
        })
    }
    
    func runScene() {
        
        // after ten seconds reveal a reset button that wipes the existing game file
        // this is rarely needed so I didn't want it visible at launch
        self.run(SKAction.wait(forDuration: 10.0), completion: {
            self.resetButton.run(SKAction.fadeIn(withDuration: 1.0))
        })
    }
    
    func exitScene() {
        let startAnimation = SKAction.animate(with: startTextures, timePerFrame: 0.0125)
        startButton.removeAllActions()
        resetButton.removeAllActions()
        resetButton.alpha = 0
        colorizeBackground()
        egg.run(SKAction.fadeOut(withDuration: 0.25))
        
        // rarely removeAllActions() fails if this function is called
        // as the reset button is fading in so simply move it off screen
        // just in case
        resetButton.position = CGPoint(x: 4000, y: 4000)

        startButton.run(startAnimation, completion: {
            self.run(SKAction.wait(forDuration: 2.0), completion: {
                self.presentNewScene(sceneName: "LevelOne")
            })
        })
    }
    
    func presentNewScene(sceneName: String) {
        if let nextScene = SKScene(fileNamed: sceneName) {
            
            #if os(iOS) || os(tvOS)
            // Set the scale mode to scale to fit the window
            if UIDevice.current.userInterfaceIdiom == .pad {
                nextScene.size = CGSize(width: 1024, height: 768)
            }
            #endif
            #if os(OSX)
            nextScene.size = CGSize(width: 1448, height: 1448)
            #endif
            
            nextScene.scaleMode = .aspectFill
            self.view?.presentScene(nextScene, transition: SKTransition.crossFade(withDuration: 2))
        }
    }

    func colorizeBackground() {
        self.run(SKAction.colorize(with: seasonColors[0]!, colorBlendFactor: 1.0, duration: 2.0))
    }

    #if os(watchOS)
    override func sceneDidLoad() {
        self.setUpScene()
    }
    #else
    override func didMove(to view: SKView) {
        self.setUpScene()
    }
    #endif
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let location = t.location(in: self)
            let touchedNode = atPoint(location)
            if touchedNode.name == "Start" || touchedNode.name == "Egg" {
                self.run(audioScore)
                exitScene()
            }
            if touchedNode.name == "Reset" {
                if tree.eraseFile() == true {
                    resetButton.run(SKAction.fadeOut(withDuration: 0))
                }
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
}
#endif

#if os(OSX)
// Mouse-based event handling
extension GameScene {

    override func mouseDown(with event: NSEvent) {

    }
    
    override func mouseDragged(with event: NSEvent) {

    }
    
    override func mouseUp(with event: NSEvent) {
        let location = event.location(in: self)
        let touchedNode = atPoint(location)
        if touchedNode.name == "Start" || touchedNode.name == "Egg" {
            self.run(audioScore)
            exitScene()
        }
        if touchedNode.name == "Reset" {
            if tree.eraseFile() == true {
                resetButton.run(SKAction.fadeOut(withDuration: 0))
            }
        }
    }
}
#endif

