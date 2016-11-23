//
//  PhotoImageView.swift
//  Pulse
//
//  Created by Alejandra Negrete on 11/20/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit
import AFNetworking
import Parse

protocol PhotoImageViewDelegate : class {
	func didSelectImage(sender: PhotoImageView)
}

class PhotoImageView: UIView {

	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet var contentView: UIView!

	var viewController: UIViewController!
	let imagePicker = UIImagePickerController()
	var imageUrl: URL?
	var photoData: Data? {
		didSet {
			self.imageView.image = UIImage(data: photoData!);
		}
	}

	var pffile: PFFile? {
		didSet {
			if let pffile = pffile {
				do {
					pffile.getDataInBackground(block: { (data: Data?, error: Error?) in
						self.photoData = data
					})
				}
			}
		}
	}

	let imageDefaultSize = 200.0

	weak var delegate:PhotoImageViewDelegate? {
		didSet {
			self.viewController = delegate as? UIViewController
		}
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initSubviews()
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		initSubviews()
	}

	func initSubviews() {
		let nib = UINib(nibName: "PhotoImageView", bundle: nil)
		nib.instantiate(withOwner: self, options: nil)
		contentView.frame = bounds
		addSubview(contentView)

		imagePicker.delegate = self
		imageView.layer.cornerRadius = 3
		imageView.clipsToBounds = true

		if let imageUrl = imageUrl {
			imageView.setImageWith(imageUrl);
		}
	}

	@IBAction func didTapProfileImageView(_ sender: UITapGestureRecognizer) {
		showAlertAction()
	}

	func showAlertAction() {

		let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

		let chooseFromLibraryAction = UIAlertAction(title: "Choose from library", style: .default) {
			(UIAlertAction) in
			self.chooseFromLibrary()
		}

		let takeProfilePhotoAction = UIAlertAction(title: "Take profile photo", style: .default) {
			(UIAlertAction) in
			self.takeProfilePhoto()
		}

		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		alertController.addAction(chooseFromLibraryAction)
		alertController.addAction(takeProfilePhotoAction)
		alertController.addAction(cancelAction)

		viewController.present(alertController, animated: true, completion: nil)
	}

	func takeProfilePhoto() {
		imagePicker.allowsEditing = false
		imagePicker.sourceType = UIImagePickerControllerSourceType.camera
		imagePicker.cameraCaptureMode = .photo
		imagePicker.modalPresentationStyle = .fullScreen
		viewController.present(imagePicker, animated: true, completion: nil)
	}

	func chooseFromLibrary() {
		imagePicker.allowsEditing = false
		imagePicker.sourceType = .photoLibrary
		viewController.present(imagePicker, animated: true, completion: nil)
	}
}

extension PhotoImageView : UIImagePickerControllerDelegate {

	public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

		if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {

			let scaledImage = resizeImage(image: chosenImage, targetSize: CGSize(width: imageDefaultSize, height: imageDefaultSize))
			photoData = UIImagePNGRepresentation(scaledImage)

			imageView.image = chosenImage;
		}

		delegate?.didSelectImage(sender: self)
		viewController.dismiss(animated: true, completion: nil)
	}

	public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		viewController.dismiss(animated: true, completion: nil)
	}

	func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
		let size = image.size

		let widthRatio  = targetSize.width  / image.size.width
		let heightRatio = targetSize.height / image.size.height

		var newSize: CGSize
		if(widthRatio > heightRatio) {
			newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
		}
		else {
			newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
		}

		let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
		UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
		image.draw(in: rect)
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		return newImage!
	}
}

extension PhotoImageView : UINavigationControllerDelegate {
}
