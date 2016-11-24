//
//  TodoEditTextCell.swift
//  Pulse
//
//  Created by Itasari on 11/22/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit
import Parse

class TodoEditTextCell: UITableViewCell {
    
    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var todoTextField: UITextField!
    @IBOutlet weak var todoLabel: UILabel!
    
    var isTodoEditing: Bool = false
    var originalTodoText: String? = nil
    
    var todoItem: PFObject! {
        didSet {
            if let text = todoItem[ObjectKeys.ToDo.text] as? String {
                todoLabel.isHidden = false
                todoTextField.isHidden = true
             
                todoLabel.text = text
                todoTextField.text = text
                
                todoTextField.delegate = self
                addTapGesture()
                originalTodoText = text
            }
        }
    }

    fileprivate func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTodoLabelTap(_:)))
        todoLabel.addGestureRecognizer(tapGesture)
        todoLabel.isUserInteractionEnabled = true
    }
    
    @objc fileprivate func onTodoLabelTap(_ sender: UITapGestureRecognizer) {
        isTodoEditing = true
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.resignFirstResponder()
        
        if let originalText = originalTodoText, todoTextField.text != originalText {
            todoItem[ObjectKeys.ToDo.text] = todoTextField.text!
            
            todoItem.saveInBackground(block: { (success: Bool, error: Error?) in
                if success {
                    debugPrint("successfully updating todoItem")
                } else {
                    debugPrint("\(error?.localizedDescription)")
                }
            })
            
            
        } else {
            debugPrint("same text, do nothing")
        }
        
        return true
    }
    
    
    
}
