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

/*
extension UIImage {
    
    func ABIResizeWith(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    func ABIResizeWith(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}*/


