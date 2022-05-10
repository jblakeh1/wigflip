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


let seasons = ["Winter", "Spring", "Summer", "Autumn"]
let whiteColor = UIColor.white
let blackColor = UIColor.black
let winterColor = UIColor(hex: "80A8B3")
let springColor = UIColor(hex: "80B1B3") // E8C27F
let summerColor = UIColor(hex: "6DA8B8")
let autumnColor = UIColor(hex: "80B1B3") // E7916A
let nightColor = UIColor(hex: "163748")
let morningColor = UIColor(hex: "E7916A")
let seasonColors = [winterColor, springColor, summerColor, autumnColor]

extension UIColor {

    //    usage
    //    let green = UIColor(hex: "12FF10")
    //    let greenWithAlpha = UIColor(hex: "12FF10AC")
    //    UIColor.blue.toHex
    //    UIColor.orange.toHex()
    //    UIColor.brown.toHex(with: true)
    
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#|;", with: "", options: .regularExpression)
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        let a, r, g, b: UInt64
        switch hexSanitized.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (rgb >> 8) * 17, (rgb >> 4 & 0xF) * 17, (rgb & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, rgb >> 16, rgb >> 8 & 0xFF, rgb & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (rgb >> 24, rgb >> 16 & 0xFF, rgb >> 8 & 0xFF, rgb & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    // MARK: - Computed Properties
    
    var toHex: String? {
        return toHex()
    }
    
    // MARK: - From UIColor to String
    
    func toHex(alpha: Bool = false) -> String? {
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)
        
        if components.count >= 4 {
            a = Float(components[3])
        }
        
        if alpha {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }
}
