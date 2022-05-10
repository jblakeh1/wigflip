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
import GameplayKit
import GameKit
import GameController

class LevelOne: SKScene {
    
    // length of day: 12 seconds
    // every 3 days: new bird event
    // every 6 days: weather event
    // every 12 days: night event (2.5 minutes)
    // every 36 days: season change event (7 minutes)
    var keyboard: GCKeyboard? = nil
    
    var lengthOfDay = Int(12)
    var strikes = Int(0)
    var gracePeriod = CGFloat(3.0)
    var audioQueue = [SKAction]()

    // unfortunately if multiple nodes fade in simultaneously,
    // seams are visible
    // a curtain that fades out is more visually elegant
    var curtain = SKNode()
    var treeContainer = SKNode()
    var canopy = SKNode()
    var trunkSprites = [SKNode]()
    var perchSprites = [SKNode]()
    var birdSprites = [SKNode]()
    var eggSprites = [SKNode]()
    var decoySprites = [SKNode]()
    var cloudSprites = [SKNode]()
    var stars = SKNode()
    var galaxies = SKNode()
    var moon = SKNode()

    var preview = SKNode()
    var caption = SKLabelNode()
    var strikeSprites = [SKNode]()
    var gameEndedOverlay = SKNode()
    var journal = SKNode()

    var moonTextures = [SKTexture]()
    var cloudTextures = [SKTexture]()
    var decoyTextures = [SKTexture]()

    var treePosX = Int(16)
    var treePosY = Int(0)
    var treeMoved = Bool(false)
    var textureIndex = Int(16)
    let tree = Tree()
    
    #if os(OSX)
    
    // there is no macOS equivalent to iOS touch.previousLocation
    // so it must be captured for drag events.
    // optionally, Mac Catalyst can be used
    var previousLocation = CGPoint(x: 0,y: 0)
    #endif

    class func newGameScene() -> GameScene {
        guard let scene = SKScene(fileNamed: "LevelOne") as? GameScene else {
            print("Failed to load LevelOne.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        return scene
    }
    
    override func didMove(to view: SKView) {
        self.setUpScene()
    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        pollInput()
    }

    func setUpScene() {
        curtain = self.childNode(withName: "Curtain")!
        
        stars = self.childNode(withName: "Stars")!
        galaxies = self.childNode(withName: "Galaxies")!
        moon = self.childNode(withName: "Moon")!

        treeContainer = self.childNode(withName: "Tree")!
        canopy = treeContainer.childNode(withName: "Canopy")!

        preview = self.childNode(withName: "Preview")!
        caption = preview.childNode(withName: "Caption") as! SKLabelNode
        if atlasPreload("ui") == true {
            if let strikeContainer = self.childNode(withName: "Strikes") {
                for index in 0...5 {
                    strikeSprites.append(strikeContainer.childNode(withName: "Strike-" + String(index))!)
                }
            }
        }

        gameEndedOverlay = self.childNode(withName: "GameOver")!
        journal = gameEndedOverlay.childNode(withName: "Journal")!

        if atlasPreload("decoys") == true {
            let atlas = SKTextureAtlas(named: "decoys")
            for index in 0...6 {
                decoyTextures.append(atlas.textureNamed("decoy-" + String(index)))
            }
        }
        if atlasPreload("moon") == true {
            let atlas = SKTextureAtlas(named: "moon")
            for index in 0...5 {
                moonTextures.append(atlas.textureNamed("moon-" + String(index)))
            }
        }
        if atlasPreload("clouds") == true {
            let atlas = SKTextureAtlas(named: "clouds")
            cloudTextures.append(atlas.textureNamed("nimbostratus-0"))
            cloudTextures.append(atlas.textureNamed("nimbostratus-1"))
            cloudTextures.append(atlas.textureNamed("nimbostratus-2"))
        }
        for spriteIndex in 0...11 {
            if let tier = treeContainer.childNode(withName: "Trunk-" + String(spriteIndex)) as? SKSpriteNode {
                trunkSprites.append(tier)
            }
            if let perch = treeContainer.childNode(withName: "Perch-" + String(spriteIndex)) as? SKSpriteNode {
                perchSprites.append(perch)
            }
            if let bird = treeContainer.childNode(withName: "Bird-" + String(spriteIndex)) as? SKSpriteNode {
                birdSprites.append(bird)
            }
            if let egg = birdSprites[spriteIndex].childNode(withName: "Egg") as? SKSpriteNode {
                eggSprites.append(egg)
            }
            if let decoy = birdSprites[spriteIndex].childNode(withName: "Decoy") as? SKSpriteNode {
                decoySprites.append(decoy)
            }
        }
        for index in 0...4 {
            cloudSprites.append(treeContainer.childNode(withName: "Cloud-" + String(index))!)
        }
        
        // preload textures
        if atlasPreload(tree.type) == true {
            
            // read game state from file
            if tree.readFromFile() == true {
                var canopyY = tree.days
                if canopyY > 480 {
                    canopyY = 480
                }
                if tree.days > 0 {
                    canopy.run((SKAction.move(to: CGPoint(x: 0, y: CGFloat(canopyY)), duration: 0)))
                }
                for perch in tree.perches {
                    if atlasPreload(perch.type) == true {
                        perch.assignTextures()
                    }
                }
                for item in tree.birds {
                    if atlasPreload(item.type) == true {
                        item.assignTextures()
                    }
                }
            } else {
                
                // no data, this is a new game
                if tree.addPerch() == true {
                    print("Perch added")
                }
            }
            redrawTree(fadeIn: false)
            runScene()
        }
    }
    
    func runScene() {
        colorizeBackground(fadeIn: false)
        loopAudio()
        curtain.run(SKAction.fadeOut(withDuration: 10.0))
        self.particleEffects(self.tree.seasonName(), pos: CGPoint(x: 0, y: 0))
        loopScene()
    }
    
    func loopScene() {
        print("Day " + String(tree.days))
        print(String(tree.perches.count) + " perches" )
        print(String(tree.birds.count) + " birds" )
        print(String(strikes))
        
        var dayHasEvent = false
        var reloop = true

        if strikes >= 6 {
            reloop = false
            dayHasEvent = true
        } else {
            reloop = true
        }
        
        if reloop == true {
            if tree.days > 0 && curtain.alpha == 0 {
                if tree.birds.count < 1 {
                    if tree.addStarter() == true {
                        print("Added new starter")
                        dayHasEvent = true
                    }
                }
                
                // weather
                if tree.days % 2 == 0 && tree.days % 12 != 0 {
                    weatherEvent("Clouds")
                    tree.singleMigration()
                    playEpisode(0)
                    dayHasEvent = true
                }
                
                // moon
                if (tree.days + 2) % 12 == 0 {
                    moonrise()
                    dayHasEvent = true
                }
                
                // night
                if tree.days % 12 == 0 && tree.days % 36 != 0 {
                    dayHasEvent = true
                    tree.migrateCowbirds()
                    sunset()
                }

                // change seasons
                if tree.days % 36 == 0 {
                    dayHasEvent = true
                    colorizeBackground(fadeIn: true)
                    particleEffects(tree.seasonName(), pos: CGPoint(x: 0, y: 0))
                    
                    // migration
                    tree.seasonalMigration()
                }
                
                // add a bird
                if tree.days > 0 && dayHasEvent == false && isGameEndedOverlayHidden() == true {
                    caption.alpha = 0
                    playEpisode(1)
                    
                }
            }
        }

        if reloop == true {
            let reloop = [
                SKAction.wait(forDuration: TimeInterval(lengthOfDay)),
                SKAction.run({self.loopScene()})
            ]
            redrawTree(fadeIn: true)

            tree.days += 1
            if tree.days % 10 == 0 {
                tree.saveToFile()
                submitScore()
            }
            self.run(SKAction.sequence(reloop))
        }
        if reloop == false {
            
            // end game
            showGameEndedOverlay()
            curtain.run(SKAction.fadeIn(withDuration: 2.0), completion: {
                if self.tree.eraseFile() == true {
                    self.gracePeriod = 3.0
                    self.strikes = 0
                    self.textureIndex = 16
                    self.tree.birds.removeAll()
                    self.tree.perches.removeAll()
                    if self.tree.addPerch() == true {
                        self.tree.saveToFile()
                    }
                    self.redrawTree(fadeIn: false)
                    self.runScene()
                    self.loopAudio()
                }
            })
        }
    }
    
    func loopAudio() {
        print("Audio")

        let reloop = [
            SKAction.wait(forDuration: TimeInterval(8.0)),
            SKAction.run({self.loopAudio()})
        ]
        if galaxies.alpha == 0 {
            if audioQueue.count == 0 {
                self.run(audioPonderosa)
            } else {
                self.run(audioQueue[0])
            }
        } else {
            self.run(audioSunset)
        }
        if strikes < 6 {
            self.run(SKAction.sequence(reloop))
        }
        audioQueue.removeAll()
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

    func isPerchVisible(_ perchIndex: Int) -> Bool {
        var visible = false
        if tree.perches[perchIndex].textureIndices[textureIndex] != 99 {
            visible = true
        }
        return visible
    }
    
    func repositionTree(_ posX: Int, posY: Int) {
        let positionY = CGFloat(posY)
        if (positionY + treeContainer.position.y) < 150 && (positionY + treeContainer.position.y) > -500 {
            for cloud in cloudSprites {
                cloud.run(SKAction.moveBy(x: 0, y: CGFloat(positionY/4), duration: 0))
            }
            treeContainer.run(SKAction.moveBy(x: 0, y: CGFloat(positionY), duration: 0))
            moon.run(SKAction.moveBy(x: 0, y: CGFloat(positionY/2), duration: 0))
            galaxies.run(SKAction.moveBy(x: 0, y: CGFloat(positionY/3), duration: 0))
            stars.run(SKAction.moveBy(x: 0, y: CGFloat(positionY/4), duration: 0))
        }

        var newPosX = posX
        if newPosX < 0 {
            newPosX += 360
        }
        
        treePosX = newPosX
        textureIndex = newPosX % 36
        redrawTree(fadeIn: false)
        
    }
    
    func redrawTree(fadeIn: Bool) {
        var duration = 0.5
        if fadeIn == false {
            duration = 0
        }
        canopy.run((SKAction.move(to: CGPoint(x: 0, y: CGFloat((tree.perches.count * 72) - 72)), duration: duration)))
        for index in 0...11 {
            if index < tree.perches.count {
                if trunkSprites[index].alpha < 1.0 {
                    trunkSprites[index].alpha = 1.0
                }
            } else {
                trunkSprites[index].alpha = 0
                perchSprites[index].alpha = 0
            }
        }

        canopy.run(SKAction.setTexture(tree.canopyTextures[textureIndex]))
        for (perchIndex, _) in tree.perches.enumerated() {
            perchSprites[perchIndex].run(SKAction.setTexture(tree.perches[perchIndex].textures[textureIndex]))
            if perchSprites[perchIndex].alpha < 1.0 {
                perchSprites[perchIndex].run(SKAction.fadeIn(withDuration: 1.0))
            }
        }
        for sprite in birdSprites {
            sprite.alpha = 0
            // sprite.run(SKAction.fadeOut(withDuration: 0))
        }
        for (index, _) in tree.birds.enumerated() {
            birdSprites[index].run(SKAction.setTexture(tree.birds[index].textures[textureIndex]))
//            let coinToss = Bool.random()
//            if coinToss == true {
//                birdSprites[index].run(SKAction.setTexture(tree.birds[index].altTextures[textureIndex]))
//            }
            birdSprites[index].run(SKAction.fadeIn(withDuration: duration))
        }
    }
    
    func spinTree() {
        print("Spin")
        if audioQueue.count == 0 {
            audioQueue.append(audioClick)
        }
        let frameTime = 0.025
        var newTextureIndex = textureIndex
        var canopyTextures = [SKTexture]()
        var perchTextures = [[SKTexture]]()
        var birdTextures = [[SKTexture]]()
        perchTextures = [[], [], [], [], [], [], [], [], [], [], [], [], [], []]
        birdTextures = [[], [], [], [], [], [], [], [], [], [], [], [], [], []]

        for _ in 0...4 {
            newTextureIndex += 1
            if newTextureIndex > 35 {
                newTextureIndex = 0
            }
            canopyTextures.append(tree.canopyTextures[newTextureIndex])
            
            // perches
            for (index, perch) in tree.perches.enumerated() {
                perchTextures[index].append(perch.textures[newTextureIndex])
            }
            
            // birds
            for (index, item) in tree.birds.enumerated() {
                birdTextures[index].append(item.textures[newTextureIndex])
            }
        }
        
        let canopyAnimation = SKAction.animate(with: canopyTextures, timePerFrame: frameTime)
        canopyAnimation.timingMode = .easeOut

        canopy.run(canopyAnimation)

        // perches
        for (index, _) in tree.perches.enumerated() {
            let perchAnimation = SKAction.animate(with: perchTextures[index], timePerFrame: frameTime)
            perchAnimation.timingMode = .easeOut
            perchSprites[index].run(perchAnimation)
        }
        
        // birds
        for (index, _) in tree.birds.enumerated() {
            let birdAnimation = SKAction.animate(with: birdTextures[index], timePerFrame: frameTime)
            birdAnimation.timingMode = .easeOut
            birdSprites[index].run(birdAnimation)
        }
        textureIndex = newTextureIndex
    }
    
    func playEpisode(_ episodeType: Int) {
         var type = episodeType
        // type 0: no eggs
        // type 1: one egg
        if type == 0 {
            let coinToss = Bool.random()
            if coinToss == true {
                type = 1
            }
        }
        print("Episode")
        audioQueue.append(audioEgg)
        if tree.birds.count > 0 && isGameEndedOverlayHidden() == true {
            var eggSpriteIndex = 99
            randomizeDecoys()
            
            if type == 1 {
                if tree.addCandidate() == true {
                    
                    // choose a random bird to throw the egg
                    eggSpriteIndex = Int(arc4random_uniform(UInt32(tree.birds.count)))
                    print("Egg sprite index:")
                    print(eggSpriteIndex)
                }
            }
            
            for (index, item) in tree.birds.enumerated() {
                var sprite = SKNode()
                var xAxis = Int(arc4random_uniform(UInt32(100))) + 100
                if item.textureIndices[textureIndex] < 8 || item.textureIndices[textureIndex] > 26 {
                    xAxis = -xAxis
                }
                let spin = SKAction.rotate(toAngle: CGFloat(arc4random_uniform(UInt32(20) + 8)), duration: TimeInterval(3.5))
                let glide = [
                    SKAction.moveBy(x: CGFloat(xAxis), y: 20.0, duration: 0.5),
                    SKAction.wait(forDuration: TimeInterval(gracePeriod)),
                    SKAction.moveTo(y: CGFloat(-2000.0), duration: 2.0),
                    SKAction.fadeOut(withDuration: 0.1),
                ]

                if index == eggSpriteIndex {
                    sprite = eggSprites[index]
                    sprite.run(SKAction.setTexture(tree.birdCandidate[0].eggTexture()))
                } else {
                    sprite = decoySprites[index]
                }
                sprite.run(SKAction.fadeIn(withDuration: 0.5))
                sprite.run(spin)
                if index == eggSpriteIndex {
                    
                    // this sprite is an egg...
                    sprite.run(SKAction.sequence(glide), completion: {
                        self.updateStrikes(1)
                        self.tree.removeCandidate()
                        self.hideEggs()
                        self.audioQueue.removeAll()
                        self.audioQueue.append(audioClick)
                    })
                } else if index == 0 && type == 0 {
                    
                    // this sprite is a decoy when there are no eggs...
                    sprite.run(SKAction.sequence(glide), completion: {
                        self.hideEggs()
                    })
                } else {
                    sprite.run(SKAction.sequence(glide))
                }
            }
        }
    }

    func hideEggs() {
        print("Eggs reset")
        let ammo = eggSprites + decoySprites
        for egg in ammo {
            egg.removeAllActions()
            egg.alpha = 0
            egg.position = CGPoint(x: 0, y: 0)
            egg.run(SKAction.rotate(toAngle: CGFloat(0), duration: TimeInterval(0)))
        }
    }
    
    func randomizeDecoys() {
        for sprite in decoySprites {
            sprite.run(SKAction.setTexture(decoyTextures[Int(arc4random_uniform(UInt32(6)))]))
        }
    }
    
    func weatherEvent(_ type: String) {
        print("Weather event")

        if type == "Clouds" {
            for index in 0...4 {
                let coinToss = Bool.random()
                if coinToss == true {
                    cloudSprites[index].run(SKAction.setTexture(cloudTextures[Int(arc4random_uniform(UInt32(3)))]))
                    let yPos = CGFloat(arc4random_uniform(UInt32(240)))
                    let duration = CGFloat(arc4random_uniform(UInt32(20))) + 10
                    cloudSprites[index].run(SKAction.moveTo(x: yPos, duration: 0))
                    cloudSprites[index].run(SKAction.moveTo(x: -yPos, duration: TimeInterval(duration)))
                    cloudSprites[index].run(SKAction.fadeIn(withDuration: TimeInterval(duration/2)), completion: {
                        self.cloudSprites[index].run(SKAction.fadeOut(withDuration: TimeInterval(duration/4)))
                    })
                }
            }
        }
    }
    
    func moonrise() {
        if let moonSprite = moon.childNode(withName: "Moon") {
            let moonCycles = [12, 24, 36, 48, 60, 72]
            for index in 0...5 {
                if (tree.days + 2) % moonCycles[index] == 0 {
                    moonSprite.run(SKAction.setTexture(moonTextures[index]))
                }
            }
        }
        moon.alpha = 0
        moon.run(SKAction.rotate(byAngle: CGFloat(Double.pi) * 2, duration: 120.0))
    }
    
    func sunset() {
        if preview.alpha > 0 {
            preview.run(SKAction.fadeOut(withDuration: 0.5))
        }
        moon.run(SKAction.fadeIn(withDuration: 4.0))
        // self.removeAllActions()
        self.run(SKAction.colorize(with: nightColor!, colorBlendFactor: 1.0, duration: 4.0))
        stars.run(SKAction.fadeIn(withDuration: 10.0), completion: {self.stars.run(SKAction.fadeOut(withDuration: 2.0))})
        galaxies.run(SKAction.fadeIn(withDuration: 10.0), completion: {self.galaxies.run(SKAction.fadeOut(withDuration: 2.0))})
        stars.run(SKAction.rotate(byAngle: CGFloat(Double.pi) * 2, duration: 60.0))
        galaxies.run(SKAction.rotate(byAngle: CGFloat(Double.pi) * 2, duration: 40.0))

        for sprite in colorSprites() {
            sprite.run(SKAction.colorize(with: blackColor, colorBlendFactor: 0.7, duration: 4.0))
        }
        self.run(SKAction.wait(forDuration: 10.0), completion: {self.sunrise()})
    }
    
    func sunrise() {
        moon.run(SKAction.fadeOut(withDuration: 4.0))
        self.run(SKAction.colorize(with: morningColor!, colorBlendFactor: 0, duration: 4.0), completion: {
            self.colorizeBackground(fadeIn: true)
        })
        uncolorSprites()
    }
    
    func colorSprites() -> [SKNode] {
        var sprites = [canopy]
        sprites.append(contentsOf: trunkSprites)
        sprites.append(contentsOf: perchSprites)
        sprites.append(contentsOf: birdSprites)
        return sprites
    }

    func colorizeBackground(fadeIn: Bool) {
        var duration = 4.0
        if fadeIn == false {
            duration = 0
        }
        self.run(SKAction.colorize(with: seasonColors[tree.seasonIndex()]!, colorBlendFactor: 1.0, duration: duration))
    }
    
    func uncolorSprites() {
        for sprite in colorSprites() {
            sprite.run(SKAction.colorize(with: whiteColor, colorBlendFactor:1.0, duration: 4.0))
        }
    }
    
    func updateStrikes(_ difference: Int) {
        strikes += difference
        print("Strikes")
        print(strikes)
        if strikes > 0 && difference > 0 {
            for index in 0...5 {
                let strikeIndex = index + 1
                if strikes >= strikeIndex {
                    strikeSprites[index].run(SKAction.fadeIn(withDuration: 1.0))
                } else {
                    strikeSprites[index].alpha = 0
                }
                if index == 5 {
                    strikeSprites[index].run(SKAction.wait(forDuration: 3.0), completion: {
                        for strike in 0...5 {
                            self.strikeSprites[strike].run(SKAction.fadeOut(withDuration: 0.5))
                            if let tip = self.strikeSprites[0].childNode(withName: "Caption") {
                                tip.run(SKAction.fadeOut(withDuration: 0.5))
                            }
                        }
                    })
                }
                if strikes > 5 {
                    for item in birdSprites {
                        item.alpha = 0
                    }
                }
            }
        }
    }

    func showCaptions() {
        if tree.birds.count > 0 {
            let previewActions = [
                SKAction.fadeOut(withDuration: 0),
                SKAction.setTexture(tree.birds[(tree.birds.count - 1)].previewTexture()),
                SKAction.fadeIn(withDuration: 1.0),
                SKAction.wait(forDuration: 5.0),
                SKAction.fadeOut(withDuration: 1.0)
            ]
            preview.run(SKAction.sequence(previewActions))
            caption.text = tree.birds[(tree.birds.count - 1)].caption()
            caption.run(SKAction.fadeIn(withDuration: 0.5))
        }
    }
        
    func showGameEndedOverlay() {
        journal.alpha = 1.0
        
        var entrySprites = [SKNode]()
        for index in 0...107 {
            let entrySprite = journal.childNode(withName: "Score-" + String(index))
            entrySprites.append(entrySprite!)
            entrySprite?.alpha = 0
        }
        
        for (entryIndex, entry) in tree.journalTextures.enumerated() {
            if entryIndex < 108 {
                entrySprites[entryIndex].run(SKAction.setTexture(SKTexture(imageNamed: entry + "-egg")))
                entrySprites[entryIndex].run(SKAction.fadeIn(withDuration: 0.5))
            }
        }

        gameEndedOverlay.run(SKAction.fadeIn(withDuration: 2.0))
    }

    func hideGameEndedOverlay() {
        gameEndedOverlay.run(SKAction.fadeOut(withDuration: 0.25))
    }
    
    func isGameEndedOverlayHidden() -> Bool {
        if gameEndedOverlay.alpha == 1 {
            return false
        } else {
            return true
        }
    }
    
    func particleEffects(_ type: String, pos: CGPoint) {
        if type == "Poof" {
            if let poofParticle = SKEmitterNode(fileNamed: "Poof.sks") {
                poofParticle.position = pos
                poofParticle.name = "Poof"
                poofParticle.targetNode = self
                self.addChild(poofParticle)
                self.run(SKAction.wait(forDuration: 10.0), completion: {self.removeParticleFX("Poof")})
            }
        }
        for season in seasons {
            if type == season {
                if let starParticle = SKEmitterNode(fileNamed: season + ".sks") {
                    starParticle.position = CGPoint.init(x: 0, y: 0)
                    starParticle.name = season
                    starParticle.targetNode = self
                    self.addChild(starParticle)
                    self.run(SKAction.wait(forDuration: 30.0), completion: {self.removeParticleFX(season)})
                }
            }
        }
    }
    
    func removeParticleFX(_ type: String) {
        if type == "Poof" {
            if let particleNode = self.childNode(withName: "Poof") {
                particleNode.removeFromParent()
            }
        }
        for season in seasons {
            if tree.seasonName() == season {
                if let particleNode = preview.childNode(withName: season) {
                    particleNode.removeFromParent()
                }
            }
        }
    }
    
    func submitScore() {
        if tree.journalTextures.count > 1 && gameKitEnabled == true {
            let localPlayer: GKLocalPlayer = GKLocalPlayer.local
            let gcScore = tree.journalTextures.count

            GKLeaderboard.submitScore(gcScore, context: 0, player: localPlayer, leaderboardIDs: [gameKitDefaultLeaderboard], completionHandler: { (error) in
                if error != nil { print(error!.localizedDescription)
                } else { print("Score submitted to GameCenter") }
            })
            
        }
    }
    
    func submitAchievements() {
        if gameKitEnabled == true {
            for item in tree.birds {
                let achievement = item.gcAchievementID()
                if achievement != "0000" && tree.achievementIDs.contains(item.gcAchievementID()) == false {
                    tree.achievementIDs.append(item.gcAchievementID())
                    
                    let gAchievement = GKAchievement(identifier: achievement)
                    gAchievement.percentComplete = 100
                    gAchievement.showsCompletionBanner = true
                    GKAchievement.report([gAchievement]){ (error) in
                        if error != nil { print(error!.localizedDescription)
                        } else { print("Achievement submitted to GameCenter") }
                    }
                }
            }
        }
    }
    
    func touchDownAgnostic(node: SKNode, pos: CGPoint) {
        if let touchedNodeName = node.name {
            print(touchedNodeName)
            
            // strike
             if touchedNodeName == "Decoy" {
                 particleEffects("Poof", pos: pos)
                 updateStrikes(1)
                 hideEggs()
                audioQueue.removeAll()
                audioQueue.append(audioClick)
             }

            // add bird
            if touchedNodeName == "Egg" {
               audioQueue.removeAll()
               audioQueue.append(audioScore)
               particleEffects("Poof", pos: pos)
               hideEggs()

                if gracePeriod > 0.75 {
                    gracePeriod -= 0.25
                }
                preview.removeAllActions()
                if tree.birdCandidate.count > 0 {
                    if tree.perches.count <= tree.birds.count {
                        if tree.addPerch() == true {
                            print("Perch added")
                        }
                    }
                    if tree.addBird() == true {
                       submitAchievements()
                       tree.saveToFile()
                       redrawTree(fadeIn: true)
                       showCaptions()
                    } else {
                        
                        // if seasons change as a candidate is vetted...
                        tree.removeCandidate()
                    }
                }
            }

        }
    }
    
    func touchUpAgnostic(node: SKNode, pos: CGPoint) {
        if let touchedNodeName = node.name {
            print(touchedNodeName)
            
            if isGameEndedOverlayHidden() == true && treeMoved == false {
                if touchedNodeName != "Decoy" && touchedNodeName != "Egg" {
                    // spinTree()
                }
            }
            if touchedNodeName == "GameOver" {
                hideGameEndedOverlay()
            }
            
            for index in 0...107 {
                let spriteName = "Score-" + String(index)
                if touchedNodeName == spriteName {
                    let entrySprite = journal.childNode(withName: spriteName)
                    entrySprite!.run(SKAction.setTexture(SKTexture(imageNamed: tree.journalTextures[index] + "-preview")))
                    break
                }
            }
            treeMoved = false
        } else {
            // spinTree()
        }
    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension LevelOne {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let location = t.location(in: self)
            let touchedNode = atPoint(location)
            touchDownAgnostic(node: touchedNode, pos: location)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            let previousLocation = touch.previousLocation(in: self)
            let differenceX = (location.x - previousLocation.x)/2
            // let differenceX = (location.y - previousLocation.y)
            let differenceY = (location.y - previousLocation.y)
            if isGameEndedOverlayHidden() == false {
                if abs(differenceY) > 20 {
                    hideGameEndedOverlay()
                }
            } else {
                if abs(differenceY) > 5 {
                    treeMoved = true
                }
                repositionTree(treePosX + Int(differenceX), posY: treePosY + Int(differenceY))
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let location = t.location(in: self)
            let touchedNode = atPoint(location)
            touchUpAgnostic(node: touchedNode, pos: location)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {

    }
}
#endif

#if os(OSX)
// Mouse-based event handling
extension LevelOne {
    
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        previousLocation = location
        let touchedNode = atPoint(location)
        touchDownAgnostic(node: touchedNode, pos: location)
    }
    
    override func mouseDragged(with event: NSEvent) {
            let location = event.location(in: self)
            let differenceX = (location.x - previousLocation.x)/2
            let differenceY = (location.y - previousLocation.y)
            if isGameEndedOverlayHidden() == false {
                if abs(differenceY) > 20 {
                    hideGameEndedOverlay()
                }
            } else {
                if abs(differenceY) > 5 {
                    treeMoved = true
                }
                repositionTree(treePosX + Int(differenceX), posY: treePosY + Int(differenceY))
                previousLocation = location
            }
    }
    
    override func mouseUp(with event: NSEvent) {
        let location = event.location(in: self)
        let touchedNode = atPoint(location)
        touchUpAgnostic(node: touchedNode, pos: location)
    }
}
#endif

