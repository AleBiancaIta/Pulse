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
	@IBOutlet weak var cameraButton: UIButton!

	weak var viewController: UIViewController!
	let imagePicker = UIImagePickerController()
	var photoData: Data? {
		didSet {
            if let photoData = photoData {
                self.imageView.image = UIImage(data: photoData)
				self.cameraButton.isHidden = true
            }
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
			else {
				initDefaultPhoto()
			}
		}
	}

	override var isUserInteractionEnabled: Bool {
		didSet {
			self.cameraButton.isHidden = !isUserInteractionEnabled
		}
	}

	var isEditable = false 
	let imageDefaultSize:CGFloat = 200.0

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
		imageView.layer.cornerRadius = 5
        imageView.layer.borderColor = UIColor.pulseLightPrimaryColor().cgColor
        imageView.layer.borderWidth = 1
		imageView.clipsToBounds = true
		initDefaultPhoto()

		let tintedImage = cameraButton.imageView?.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
		cameraButton.imageView?.tintColor = UIColor.pulseLightPrimaryColor()
		cameraButton.imageView?.image = tintedImage

		imageView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            self.imageView.alpha = 1
        })
	}

	func initDefaultPhoto() {
		imageView.image = #imageLiteral(resourceName: "DefaultPhoto0")
	}

	@IBAction func didTapProfileImageView(_ sender: UITapGestureRecognizer) {
		if isEditable {
			showAlertAction()
		}
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

			let scaledImage = chosenImage.resize(to: imageDefaultSize)
			photoData = UIImagePNGRepresentation(scaledImage)

			imageView.image = chosenImage;
		}

		delegate?.didSelectImage(sender: self)
		viewController.dismiss(animated: true, completion: nil)
	}

	public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		viewController.dismiss(animated: true, completion: nil)
	}
}

extension PhotoImageView : UINavigationControllerDelegate {
}
