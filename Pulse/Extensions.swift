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
            RKDropdownAlert.title(title, message: message, backgroundColor: UIColor.pulseAlertBackgroundColor(), textColor: UIColor.pulseAlertTextColor(), time: 2)
        case .success:
            RKDropdownAlert.title(title, message: message, backgroundColor: UIColor.pulseSuccessBackgroundColor(), textColor: UIColor.pulseSuccessTextColor(), time: 2)
        case .failure:
            RKDropdownAlert.title(title, message: message, backgroundColor: UIColor.pulseFailureBackgroundColor(), textColor: UIColor.pulseFailureTextColor(), time: 2)
        }
    }
    
    func  ABIShowDropDownAlertWithDelegate(type: AlertTypes , title: String, message: String, delegate: RKDropdownAlertDelegate!) {
        switch type {
        case .alert:
            RKDropdownAlert.title(title, message: message, backgroundColor: UIColor.pulseAlertBackgroundColor(), textColor: UIColor.pulseAlertTextColor(), time: 2, delegate: delegate)
        case .success:
            RKDropdownAlert.title(title, message: message, backgroundColor: UIColor.pulseSuccessBackgroundColor(), textColor: UIColor.pulseSuccessTextColor(), time: 2, delegate: delegate)
        case .failure:
            RKDropdownAlert.title(title, message: message, backgroundColor: UIColor.pulseFailureBackgroundColor(), textColor: UIColor.pulseFailureTextColor(), time: 2, delegate: delegate)
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
				UIApplication.shared.open(emailUrl, options: [:], completionHandler: nil)
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
