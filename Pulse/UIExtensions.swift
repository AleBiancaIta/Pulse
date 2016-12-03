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
     * Fade in duration: 1
     * Primary text color (light background): Black
     * Primary text color (dark background): White
     */
    
    class func gradientBackgroundFor(view: UIView) {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor.black.cgColor, UIColor.pulseBackgroundColor().cgColor]
        view.layer.insertSublayer(gradient, at: 0)
    }
    
    // This textfield setup only shows well for dark backgrounds
    class func setupViewFor(textField: UITextField) {
        let border = CALayer()
        border.borderColor = UIColor.pulseLightPrimaryColor().cgColor
        border.frame = CGRect(x: 0, y: textField.frame.size.height - 1, width:  textField.frame.size.width, height: textField.frame.size.height)
        border.borderWidth = 1
        textField.layer.addSublayer(border)
        textField.layer.masksToBounds = true
        textField.backgroundColor = UIColor.clear
        textField.textColor = UIColor.white
        if let placeholder = textField.placeholder {
            textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes:[NSForegroundColorAttributeName: UIColor.pulseDividerColor()])
        }
    }
    
    // This textfield setup only shows well for light backgrounds
    class func setupDarkViewFor(textField: UITextField) {
        let border = CALayer()
        border.borderColor = UIColor.pulseDarkPrimaryColor().cgColor
        border.frame = CGRect(x: 0, y: textField.frame.size.height - 1, width:  textField.frame.size.width, height: textField.frame.size.height)
        border.borderWidth = 1
        textField.layer.addSublayer(border)
        textField.layer.masksToBounds = true
        textField.backgroundColor = UIColor.clear
        textField.textColor = UIColor.black
        if let placeholder = textField.placeholder {
            textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes:[NSForegroundColorAttributeName: UIColor.pulseDividerColor()])
        }
    }
    
    // Convenience method to convert hex to UIColor
    class func uiColorWith(hex: String) -> UIColor {
        return uiColorWith(hex: hex, alpha: 1.0)
    }
    
    class func uiColorWith(hex: String, alpha: Float) -> UIColor {
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
            alpha: CGFloat(alpha)
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
    
    // Used for secondary text on dark background
    class func pulseLightPrimaryColor() -> UIColor {
        return UIExtensions.uiColorWith(hex: "#C5CAE9") // Light indigo
    }
    
    // Used for secondary text on light background
    class func pulseSecondaryTextColor() -> UIColor {
        return UIExtensions.uiColorWith(hex: "#757575")
    }

    // Used for graph line, text links, and clear background icons
    class func pulseAccentColor() -> UIColor {
        return UIExtensions.uiColorWith(hex: "#536DFE") // Bright indigo
    }
    
    // Used for clear textfields with dark background
    class func pulseDividerColor() -> UIColor {
        return UIExtensions.uiColorWith(hex: "#BDBDBD") // Light grey
    }
    
    // MARK: - Alert Colors
    
    class func pulseSuccessBackgroundColor() -> UIColor {
        return UIExtensions.uiColorWith(hex: "#303F9F", alpha: 0.9)
    }
    
    class func pulseFailureBackgroundColor() -> UIColor {
        return UIExtensions.uiColorWith(hex: "#303F9F", alpha: 0.9)
    }
    
    class func pulseAlertBackgroundColor() -> UIColor {
        return UIExtensions.uiColorWith(hex: "#303F9F", alpha: 0.9)
    }
    
    class func pulseSuccessTextColor() -> UIColor {
        return UIColor.white
    }

    class func pulseFailureTextColor() -> UIColor {
        return UIColor.white
    }

    class func pulseAlertTextColor() -> UIColor {
        return UIColor.white
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
        return UIColor.clear
    }
}
