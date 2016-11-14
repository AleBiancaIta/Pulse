//
//  Extensions.swift
//  Pulse
//
//  Created by Itasari on 11/11/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(title: String, message: String, sender: Any?, handler: ((UIAlertAction)->())?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: handler)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertWithActions(title: String, message: String, actionTitle1: String, actionTitle2: String, sender: Any?, handler1: ((UIAlertAction)->())?, handler2: ((UIAlertAction)->())?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: actionTitle1, style: .default, handler: handler1))
        alertController.addAction(UIAlertAction(title: actionTitle2, style: .default, handler: handler2))
        self.present(alertController, animated: true, completion: nil)
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

