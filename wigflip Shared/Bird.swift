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

let birdOptions = ["black-bird", "black-capped-chickadee", "blue-jay", "cardinal", "cowbird", "flicker", "monk-parakeet", "pine-warbler", "purple-finch", "scissor-tailed-flycatcher"]

class Bird: NSObject {
    var type = String("blue-jay")
    var startPosition = Int(0)
    
    // Each spinning object has 36 textures, each representing 10 degrees of the
    // rotation. To avoid storing lots of empty texture files (for example, when the
    // bird or perch is obscured behind the tree), each of the spinning objects
    // stores an array of texture indices so a single empty texture can be reused
    var textures = [SKTexture]()
    var altTextures = [SKTexture]()
    var textureIndices = [Int]()

    
    func eggTexture() -> SKTexture {
        return SKTexture(imageNamed: type + "-egg")
    }
    
    func previewTexture() -> SKTexture {
        return SKTexture(imageNamed: type + "-preview")
    }
    
    func seasons() -> [Int] {
           let seasons: [Int]
           switch type {
           case "black-bird":
               seasons = [1, 2]
            case "black-capped-chickadee":
                seasons = [1, 2]
           case "blue-jay":
               seasons = [2, 3]
           case "cardinal":
               seasons = [0, 2]
           case "cowbird":
               seasons = [0, 1, 2, 3]
           case "flicker":
               seasons = [1, 3]
           case "hummingbird":
               seasons = [1, 2, 3]
           case "monk-parakeet":
               seasons = [1, 2]
           case "pine-warbler":
               seasons = [0]
           case "purple-finch":
               seasons = [0, 3]
           case "scissor-tailed-flycatcher":
               seasons = [2]
           default:
               seasons = [0, 1, 2, 3]
           }
           return seasons
       }
       
       func caption() -> String {
            let caption: String
            switch type {
            case "black-bird":
                caption = NSLocalizedString("Red-winged blackbird", comment: "")
            case "black-capped-chickadee":
                caption = NSLocalizedString("Black-capped chickadee", comment: "")
            case "blue-jay":
                caption = NSLocalizedString("Steller’s jay", comment: "")
            case "cardinal":
                caption = NSLocalizedString("Northern cardinal", comment: "")
            case "cowbird":
                caption = NSLocalizedString("Cowbird", comment: "")
            case "flicker":
                caption = NSLocalizedString("Common flicker", comment: "")
            case "hummingbird":
                caption = NSLocalizedString("Rufous hummingbird", comment: "")
            case "monk-parakeet":
                caption = NSLocalizedString("Monk parakeet", comment: "")
            case "pine-warbler":
                caption = NSLocalizedString("Pine warbler", comment: "")
            case "purple-finch":
                caption = NSLocalizedString("Purple finch", comment: "")
            case "scissor-tailed-flycatcher":
                caption = NSLocalizedString("Scissor-tailed flycatcher", comment: "")
            default:
                caption = NSLocalizedString("Bird", comment: "")
                
            }
        return caption
    }

    func gcAchievementID() -> String {
        let gcAchievementID: String
        switch type {
        case "black-bird":
            gcAchievementID = "0001"
        case "black-capped-chickadee":
            gcAchievementID = "0002"
        case "blue-jay":
            gcAchievementID = "0003"
        case "cardinal":
            gcAchievementID = "0004"
         case "cowbird":
             gcAchievementID = "0000"
         case "flicker":
             gcAchievementID = "0005"
        case "hummingbird":
            gcAchievementID = "0000"
        case "monk-parakeet":
            gcAchievementID = "0006"
        case "pine-warbler":
            gcAchievementID = "0007"
        case "purple-finch":
            gcAchievementID = "0009"
        case "scissor-tailed-flycatcher":
            gcAchievementID = "0008"
        default:
            gcAchievementID = "0000"
        }
        return gcAchievementID
    }

    func assignTextures() {
        textureIndices = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99]
        for _ in 0...startPosition {
            let x = textureIndices[0]
            textureIndices.remove(at: 0)
            textureIndices.append(x)
        }
        let atlas = SKTextureAtlas(named: type)
        textures.removeAll()
        altTextures.removeAll()
        for index in textureIndices {
            textures.append(atlas.textureNamed(type + "-" + String(index)))
            altTextures.append(atlas.textureNamed(type + "-alt-" + String(index)))
        }
    }
}
