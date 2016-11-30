//
//  UIExtensions.swift
//  Pulse
//
//  Created by Bianca Curutan on 11/26/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit

class UIExtensions: NSObject {
    /* UI Notes:
     * Corner radius: 5.0
     * Header font: Helvetica Neue thin 24pt
     * Subheader font: Helvetica Neue thin 17pt
     */
    
    /* TODO - other things to address:
     * Font size/attributes/type -- headers, subheaders, primary, button text, cell text, etc
     * Assets (need all buttons, default pics, etc. to look the same) - TODO Ita
     */
    
    class func gradientBackgroundFor(view: UIView) {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor.black.cgColor, UIColor.pulseBackgroundColor().cgColor]
        view.layer.insertSublayer(gradient, at: 0)
    }
    
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
    
    /* Other color notes:
     * Black: Used for primary text on light backgrounds
     * White: Used for primary text on dark backgrounds
     */
    
    // Used in background gradient with black
    class func pulseBackgroundColor() -> UIColor {
        return UIExtensions.uiColorWith(hex: "#303F9F") // Darker indigo
    }
    
    class func pulseDarkPrimaryColor() -> UIColor {
        return UIExtensions.uiColorWith(hex: "#303F9F") // Darker indigo
    }
    
    // Used for buttons
    class func pulsePrimaryColor() -> UIColor {
        return UIExtensions.uiColorWith(hex: "#3F51B5") // Indigo
    }
    
    // Used for secondary text
    class func pulseLightPrimaryColor() -> UIColor {
        return UIExtensions.uiColorWith(hex: "#C5CAE9") // Light indigo
    }

    // Used for graph line, text links, and clear background icons
    class func pulseAccentColor() -> UIColor {
        return UIExtensions.uiColorWith(hex: "#536DFE") // Bright indigo
    }
    
    // MARK: - Alert Colors
    
    class func pulseSuccessBackgroundColor() -> UIColor {
        return UIExtensions.uiColorWith(hex: "#3F51B5") // TODO Bianca
    }
    
    class func pulseFailureBackgroundColor() -> UIColor {
        return UIExtensions.uiColorWith(hex: "#C5CAE9") // TODO Bianca
    }
    
    class func pulseAlertBackgroundColor() -> UIColor {
        return UIExtensions.uiColorWith(hex: "#536DFE") // TODO Bianca
    }
    
    class func pulseSuccessTextColor() -> UIColor {
        return UIColor.white
        //return UIExtensions.uiColorWith(hex: <#T##String#>)
    }

    class func pulseFailureTextColor() -> UIColor {
        return UIColor.white
        //return UIExtensions.uiColorWith(hex: <#T##String#>)
    }

    class func pulseAlertTextColor() -> UIColor {
        return UIColor.white
        //return UIExtensions.uiColorWith(hex: <#T##String#>)
    }
    
    // MARK: - Survey Colors
    class func pulseGoodSurveyColor() -> UIColor {
        return UIExtensions.uiColorWith(hex: "#A5D6A7") // Green
    }
    
    class func pulseNeutralSurveyColor() -> UIColor {
        return UIExtensions.uiColorWith(hex: "#FFE082") // Yellow
    }
    
    class func pulseBadSurveyColor() -> UIColor {
        return UIExtensions.uiColorWith(hex: "#EF9A9A") // Red
    }
    
    class func pulseNoDataSurveyColor() -> UIColor {
        return UIColor.darkGray
    }
}
