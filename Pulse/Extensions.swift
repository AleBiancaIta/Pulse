//
//  Extensions.swift
//  Pulse
//
//  Created by Itasari on 11/11/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import Parse
import UIKit

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
            let navController = UINavigationController(rootViewController: personViewController)
            personViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(onCancelButton(_:)))
            present(navController, animated: true, completion: nil)
        } else {
            show(personViewController, sender: nil)
        }
	}
    
    @objc fileprivate func onCancelButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

extension UIApplication {

	func callNumber(phoneNumber: String) {
		if let phoneCallURL = URL(string:"tel://\(phoneNumber)") {
			if (self.canOpenURL(phoneCallURL)) {
				self.open(phoneCallURL, options: [:], completionHandler: nil)
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

	func isValidPhone() -> Bool {
		let phoneRegEx = "^\\d{3}-\\d{3}-\\d{4}$"
		let phonePredicate = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)
		return phonePredicate.evaluate(with: self)
	}
}
