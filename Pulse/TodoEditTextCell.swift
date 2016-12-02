//
//  TodoEditTextCell.swift
//  Pulse
//
//  Created by Itasari on 11/22/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit
import Parse

@objc protocol TodoEditTextCellDelegate {
    @objc optional func todoEditTextCell(_ todoEditTextCell: TodoEditTextCell, didEdit: Bool)
    @objc optional func todoEditTextCell(_ todoEditTextCell: TodoEditTextCell, didSave: Bool)
}

class TodoEditTextCell: UITableViewCell {
    
    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var todoTextField: UITextField!
    @IBOutlet weak var todoLabel: UILabel!
    
    var originalTodoText: String? = nil
    weak var delegate: TodoEditTextCellDelegate?
    
    var todoItem: PFObject! {
        didSet {
            addTapGesture()
            if let text = todoItem[ObjectKeys.ToDo.text] as? String {
                todoLabel.isHidden = false
                todoTextField.isHidden = true
             
                todoLabel.text = text
                todoTextField.text = text
                
                todoTextField.delegate = self
                originalTodoText = text
            }
        }
    }

    fileprivate func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTodoLabelTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        todoLabel.addGestureRecognizer(tapGesture)
        todoLabel.isUserInteractionEnabled = true
    }
    
    @objc fileprivate func onTodoLabelTap(_ sender: UITapGestureRecognizer) {
        todoTextField.isHidden = false
        todoLabel.isHidden = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCellBackgroundView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Helpers
    fileprivate func configureCellBackgroundView() {
        cellBackgroundView.layer.cornerRadius = 5.0
        cellBackgroundView.layer.borderWidth = 1.0
        cellBackgroundView.layer.borderColor = UIColor.darkGray.cgColor
        cellBackgroundView.layer.shadowRadius = 5.0
        cellBackgroundView.layer.shadowColor = UIColor.black.cgColor
        cellBackgroundView.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
    }
}

extension TodoEditTextCell: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.becomeFirstResponder()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.resignFirstResponder()
        todoTextField.isHidden = true
        todoLabel.isHidden = false
        
        if let originalText = originalTodoText, todoTextField.text != originalText {
            todoItem[ObjectKeys.ToDo.text] = todoTextField.text!
            todoLabel.text = todoTextField.text
            originalTodoText = todoTextField.text
            delegate?.todoEditTextCell?(self, didEdit: true)
            
            todoItem.saveInBackground { (success: Bool, error: Error?) in
                if success {
                    debugPrint("successfully updating todoItem")
                    self.delegate?.todoEditTextCell?(self, didSave: true)
                } else {
                    debugPrint("Failed to save changes at this time, please try again later. Error: \(error?.localizedDescription)")
                }
            }
        } else {
            debugPrint("same text, do nothing")
        }
        return true
    }
}
