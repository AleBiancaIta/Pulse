//
//  ImageViewController.swift
//  Pulse
//
//  Created by Alejandra Negrete on 11/13/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {

	let imagePicker = UIImagePickerController()

	@IBOutlet weak var imageView: UIImageView!


	override func viewDidLoad() {
		super.viewDidLoad()
		imagePicker.delegate = self
	}


	@IBAction func shootPhoto(sender: UIBarButtonItem){
	}
	@IBAction func photofromLibrary(sender: UIBarButtonItem) {
		imagePicker.allowsEditing = false
		imagePicker.sourceType = .photoLibrary
		present(imagePicker, animated: true, completion: nil)
	}

}

extension ImageViewController : UIImagePickerControllerDelegate {

	public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		NSLog("Did finishing picking media")
		let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
		imageView.contentMode = .scaleAspectFit
		imageView.image = chosenImage
		dismiss(animated: true, completion: nil)
	}

	public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		NSLog("Did cancel")
		dismiss(animated: true, completion: nil)
	}
}

extension ImageViewController : UINavigationControllerDelegate {

}
