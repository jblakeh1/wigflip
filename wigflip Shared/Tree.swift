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

import Foundation
import SpriteKit
import GameplayKit


class Tree: NSObject {
    var days = Int(0)
    
    // option for more tree types in the future
    var type = String("ponderosa")
    var canopyTextures = [SKTexture]()

    // the journal is a visual represenation of the final score
    // as eggs are captured, the image IDs are stored in this string
    var journalTextures = [String]()
    
    // Game Center achievements
    var achievementIDs = [String]()

    var perches = [Perch]()
    var birds = [Bird]()
    
    // when adding a new bird, a candidate is chosen based on seasonality
    var birdCandidate = [Bird]()

    override init() {
        super.init()
                
        let textureIndices = [0, 1, 2, 3, 4, 5, 6, 7, 8, 0, 1, 2, 3, 4, 5, 6, 7, 8, 0, 1, 2, 3, 4, 5, 6, 7, 8, 0, 1, 2, 3, 4, 5, 6, 7, 8]
        let atlas = SKTextureAtlas(named: type)
        for index in textureIndices {
            canopyTextures.append(atlas.textureNamed("canopy-" + type + "-" + String(index)))
        }
    }
    
    func seasonIndex() -> Int {
        var seasonIndex = 0
        
        var dayOfYear = days
        if dayOfYear > 144 {
            dayOfYear %= 144
        }
        if dayOfYear >= 36 {
            seasonIndex = 1
        }
        if dayOfYear >= 72 {
            seasonIndex = 2
        }
        if dayOfYear >= 108 {
            seasonIndex = 3
        }
        return seasonIndex
    }

    func seasonName() -> String {
        return seasons[seasonIndex()]
    }
    
    func addPerch() -> Bool {
        var perchAdded = false
        if perches.count < 12 {
            let perch = Perch()
            
            // set the perch type (currently there is only one option)
            perch.type = perchOptions[Int(arc4random_uniform(UInt32(perchOptions.count)))]
            
            // set the startPos
            if perches.count < 1 {
                perch.startPosition = 24
            } else {
                var pos = perches[perches.count - 1].startPosition
                pos += 9
                if pos >= 35 {
                    pos -= 35
                }
                perch.startPosition = pos
            }
            
            if atlasPreload(perch.type) == true {
                perches.append(perch)
                perch.assignTextures()
                perchAdded = true
            }
        }
        return perchAdded
    }
    
    func hasBirdOfType(type: String) -> Bool {
        var hasBird = false
        for item in birds {
            if item.type == type {
                hasBird = true
            }
        }
        return hasBird
    }
    
    func seasonalBirdOptions() -> [String] {
        var inSeason = [String]()
        for option in birdOptions {
            let item = Bird()
            item.type = option
            if item.seasons().contains(seasonIndex()){
                inSeason.append(option)
            }
        }
        return inSeason
    }
    
    // add a bird to start the game
    func addStarter() -> Bool {
        var candidateAdded = false
        if birds.count < 12 {
            let candidate = Bird()
            
            // set the type
            if seasonalBirdOptions().count > 0 {
                if birds.count < 2 {
                    candidate.type = "cowbird"
                } else {
                    candidate.type = seasonalBirdOptions()[Int(arc4random_uniform(UInt32(seasonalBirdOptions().count)))]
                }
                birdCandidate.append(candidate)
                if addBird() == true {
                    candidateAdded = true
                }
            }
        }
        return candidateAdded
    }
    
    func addCandidate() -> Bool {
        var candidateAdded = false
        if birds.count < 12 {
            let candidate = Bird()
            
            // set the type
            if seasonalBirdOptions().count > 0 {
                candidate.type = seasonalBirdOptions()[Int(arc4random_uniform(UInt32(seasonalBirdOptions().count)))]
                birdCandidate.append(candidate)
                candidateAdded = true
            }
        }
        return candidateAdded
    }
    
    func removeCandidate() {
        if birdCandidate.count > 0 {
            birdCandidate.removeAll()
        }
    }
    
    func addBird() -> Bool {
        var birdAdded = false
        if birds.count < 12 {
            if birdCandidate.count > 0 {
                let item = birdCandidate[0]
                // is it in season?
                if item.seasons().contains(seasonIndex()) == true {
                    
                    // set the startPos
                    let perchPosition = birds.count
                    item.startPosition = perches[perchPosition].startPosition
                    
                    if atlasPreload(item.type) == true {
                        birds.append(item)
                        item.assignTextures()
                        journalTextures.append(item.type)
                        birdAdded = true
                    } else {
                        print("Atlas not found")
                    }
                } else {
                    print("Candidate out of season")
                }
            } else {
                print("Missing bird candidate")
            }
        }
        removeCandidate()
        return birdAdded
    }
    
    func seasonalMigration() {
        for item in birds {
            if item.seasons().contains(seasonIndex()) == false {
                birds.remove(at: birds.firstIndex(of: item)!)
            }
        }
        resetPositons()
    }
    func singleMigration() {
        if birds.count > 11 {
            birds.remove(at: 0)
        }
        resetPositons()
    }

    func migrateCowbirds() {
        for item in birds {
            if item.type == "cowbird" {
                birds.remove(at: birds.firstIndex(of: item)!)
            }
        }
        resetPositons()
    }
    
    func resetPositons() {
        for (index, item) in birds.enumerated() {
            item.startPosition = perches[index].startPosition
            item.assignTextures()
        }
    }
    
    // read and write data to a JSON file
    func readFromFile() -> Bool {
        let url : NSURL = getPathToFile() as NSURL
        var foundStoredData = false
        if let gameData = NSData(contentsOf: url as URL) {
            do {
                let foundData =
                    try JSONSerialization.jsonObject(
                        with: gameData as Data,
                        options: JSONSerialization.ReadingOptions()) as? [String:AnyObject]
                let jsonTest = foundData!["days"] as! Int
                if jsonTest > 0 {
                    print("Data found in file.")
                    
                    // assign data to variables here
                    days = foundData!["days"] as! Int
                    journalTextures = foundData!["journalTextures"] as! [String]
                    if foundData!["achievementIDs"] != nil {
                        achievementIDs = foundData!["achievementIDs"] as! [String]
                    }

                    
                    
                    let perchTypes = foundData!["perchTypes"] as! [String]
                    let perchPos = foundData!["perchPos"] as! [Int]

                    if perchTypes.count > 0 {
                        for index in 0...(perchTypes.count - 1) {
                            let perch = Perch()
                            perch.type = perchTypes[index]
                            perch.startPosition = perchPos[index]
                            perches.append(perch)
                        }
                    }
                
                    foundStoredData = true
                }
            } catch let error as NSError {
                    print("No file found: \(error)")
                }
        }
        return foundStoredData
    }
    
    func saveToFile() {
        print("Saving game state: \(days)")
        var informationToSave = [
            "days": days,
            ] as [String : Any]
        
        // perches
        var perchTypes = [String]()
        var perchPos = [Int]()
        for perch in perches {
            perchTypes.append(perch.type)
            perchPos.append(perch.startPosition)
        }
        informationToSave["perchTypes"] = perchTypes
        informationToSave["perchPos"] = perchPos
        
        informationToSave["journalTextures"] = journalTextures
        informationToSave["achievementIDs"] = achievementIDs

        let url : NSURL = getPathToFile() as NSURL
        
        let dataToSave: NSData?
        do {
            dataToSave = try JSONSerialization.data(withJSONObject: informationToSave,
                                                    options: JSONSerialization.WritingOptions()) as NSData?
        } catch let error as NSError {
            print("Failed to convert to JSON! \(error)")
            dataToSave = nil
        }
        dataToSave?.write(to: url as URL, atomically: true)
    }

    func eraseFile() -> Bool {
        days = 0
        saveToFile()
        return true
    }

    func getPathToFile() -> URL {
        return (FileManager.default
            .urls(for: FileManager.SearchPathDirectory.documentDirectory,
                  in: FileManager.SearchPathDomainMask.userDomainMask).last!)
            .appendingPathComponent("wigflip16.json")
    }
}
