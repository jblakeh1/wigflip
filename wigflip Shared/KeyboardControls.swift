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
import GameController

extension LevelOne {

    func pollInput() {
        
        // Game controller keyboards
        if let keyboard = GCKeyboard.coalesced?.keyboardInput {
          if (keyboard.button(forKeyCode: .spacebar)?.isPressed ?? false) {
              self.spinTree()
          }
        }
    }
    
    #if os(OSX)
    
    // mac keyboard
    public override func keyDown(with event: NSEvent) {
        if event.modifierFlags.contains(NSEvent.ModifierFlags.numericPad) {
            // arrow keys
        } else {
            if let characters = event.characters{
                for character in characters {
                    switch character {
                    case " ":
                        spinTree()
                    default:
                        break
                    }
                }
            }
        }
    }
    #endif
}
