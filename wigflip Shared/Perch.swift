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

// allows for additional perch options in the future
let perchOptions = ["perch-1"]

class Perch: NSObject {
    var type = String("perch-1")
    var startPosition = Int(0)
    
    // Each spinning object has 36 textures, each representing 10 degrees of the
    // rotation. To avoid storing lots of empty texture files (for example, when the
    // bird or perch is obscured behind the tree), each of the spinning objects
    // stores an array of texture indices so a single empty texture can be reused

    var textures = [SKTexture]()
    var textureIndices = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99]

    override init() {
        super.init()
        
    }
    
    func assignTextures() {
        for _ in 0...startPosition {
            let x = textureIndices[0]
            textureIndices.remove(at: 0)
            textureIndices.append(x)
        }
        let atlas = SKTextureAtlas(named: type)
        for index in textureIndices {
            textures.append(atlas.textureNamed(type + "-" + String(index)))
        }
    }
}
