//
//  Extensions.swift
//  Pulse
//
//  Created by Itasari on 11/11/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import Parse
import UIKit
import RKDropdownAlert

extension UIViewController {
    func ABIShowAlert(title: String, message: String, sender: Any?, handler: ((UIAlertAction)->())?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: handler)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func ABIShowAlertWithActions(title: String, message: String, actionTitle1: String, actionTitle2: String, sender: Any?, handler1: ((UIAlertAction)->())?, handler2: ((UIAlertAction)->())?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: actionTitle1, style: .default, handler: handler1))
        alertController.addAction(UIAlertAction(title: actionTitle2, style: .default, handler: handler2))
        self.present(alertController, animated: true, completion: nil)
    }

	func ABIShowPersonViewController(personPFObject: PFObject?) {
		navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
		let personViewController = UIStoryboard(name: "Person2", bundle: nil).instantiateViewController(withIdentifier: "Person2DetailsViewController") as! Person2DetailsViewController
		if let personPFObject = personPFObject {
			personViewController.personPFObject = personPFObject
		}
        if nil == personPFObject {
            navigationController?.pushViewController(personViewController, animated: true)
        } else {
            show(personViewController, sender: nil)
        }
	}
    
    func  ABIShowDropDownAlert(type: AlertTypes , title: String, message: String) {
        switch type {
        case .alert:
            RKDropdownAlert.title(title, message: message, backgroundColor: UIColor.pulseAlertBackgroundColor(), textColor: UIColor.pulseAlertTextColor(), time: 1)
        case .success:
            RKDropdownAlert.title(title, message: message, backgroundColor: UIColor.pulseSuccessBackgroundColor(), textColor: UIColor.pulseSuccessTextColor(), time: 1)
        case .failure:
            RKDropdownAlert.title(title, message: message, backgroundColor: UIColor.pulseFailureBackgroundColor(), textColor: UIColor.pulseFailureTextColor(), time: 1)
        }
    }
    
    func  ABIShowDropDownAlertWithDelegate(type: AlertTypes , title: String, message: String, delegate: RKDropdownAlertDelegate!) {
        switch type {
        case .alert:
            RKDropdownAlert.title(title, message: message, backgroundColor: UIColor.pulseAlertBackgroundColor(), textColor: UIColor.pulseAlertTextColor(), time: 1, delegate: delegate)
        case .success:
            RKDropdownAlert.title(title, message: message, backgroundColor: UIColor.pulseSuccessBackgroundColor(), textColor: UIColor.pulseSuccessTextColor(), time: 1, delegate: delegate)
        case .failure:
            RKDropdownAlert.title(title, message: message, backgroundColor: UIColor.pulseFailureBackgroundColor(), textColor: UIColor.pulseFailureTextColor(), time: 1, delegate: delegate)
        }
    }
    
    @objc fileprivate func onCancelButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

extension UIApplication {

	func call(phoneNumber: String) {
		if let phoneCallURL = URL(string:"tel://\(phoneNumber.digits)") {
			if canOpenURL(phoneCallURL) {
				open(phoneCallURL, options: [:], completionHandler: nil)
			}
		}
	}

	func mailTo(email: String) {
		if let emailUrl = URL(string: "mailto:\(email)") {
			if canOpenURL(emailUrl) {
				open(emailUrl, options: [:], completionHandler: nil)
			}
		}
	}
}

extension String {

	func isValidEmail() -> Bool {
		let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
		let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
		return emailPredicate.evaluate(with: self)
	}

	var digits: String {
		return components(separatedBy: CharacterSet.decimalDigits.inverted)
			.joined(separator: "")
	}
}

extension UIView {
    
    func shake(count: Float? = nil, forDuration duration: Double? = nil, withTranslation translation: Float? = nil) {
        let shakeAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        shakeAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        shakeAnimation.autoreverses = true
        shakeAnimation.repeatCount = count ?? 2.0
        shakeAnimation.duration = (duration ?? 0.5)/Double(shakeAnimation.repeatCount)
        shakeAnimation.byValue = translation ?? -5.0
        layer.add(shakeAnimation, forKey: "shake")
    }
}

extension UIImage {

	func resize(to: CGFloat) -> UIImage {
		return resize(toSize: CGSize(width: to, height: to))
	}

	func resize(toSize: CGSize) -> UIImage {

		let size = self.size
		let widthRatio  = toSize.width  / self.size.width
		let heightRatio = toSize.height / self.size.height

		var newSize: CGSize
		if(widthRatio > heightRatio) {
			newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
		}
		else {
			newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
		}

		let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
		UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
		self.draw(in: rect)

		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		return newImage!
	}
}
