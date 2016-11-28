//
//  UIExtensions.swift
//  Pulse
//
//  Created by Bianca Curutan on 11/26/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit

class UIExtensions: NSObject {
    /* TODO - other things to address:
     * Card appearance - TODO Bianca
     * Colors - TODO Bianca
     * Font size/attributes/type
     * Constraints (spacing)
     * Button, textfield, etc. appearance (corner radius, etc.)
     * Assets (need all buttons, default pics, etc. to look the same) - TODO Ita
     * Headers
     */
    
    // Convenience method to convert hex to UIColor
    class func uiColorWith(hex: String) -> UIColor {
        var colorString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if colorString.hasPrefix("#") {
            colorString.remove(at: colorString.startIndex)
        }
        if colorString.characters.count != 6 {
            return UIColor.gray
        }
        
        var rgbValue: UInt32 = 0
        Scanner(string: colorString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension UIColor {
    
    class func pulseBarTintColor() -> UIColor {
        return UIExtensions.uiColorWith(hex: "#1976D2") // Blue
    }
    
    class func pulseTintColor() -> UIColor {
        return UIColor.white
    }
}
