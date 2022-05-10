//
//  NSColorUtilities.swift
//  wigflip macOS
//
//  Created by James B Harris on 7/14/20.
//

import Foundation
import SpriteKit

let seasons = ["Winter", "Spring", "Summer", "Autumn"]
let whiteColor = NSColor.white
let blackColor = NSColor.black
let winterColor = NSColor(hex: "80A8B3")
let springColor = NSColor(hex: "80B1B3") // E8C27F
let summerColor = NSColor(hex: "6DA8B8")
let autumnColor = NSColor(hex: "80B1B3") // E7916A
let nightColor = NSColor(hex: "163748")
let morningColor = NSColor(hex: "E7916A")
let seasonColors = [winterColor, springColor, summerColor, autumnColor]

extension NSColor {
    
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

