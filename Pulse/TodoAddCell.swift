//
//  TodoAddCell.swift
//  Pulse
//
//  Created by Itasari on 11/19/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit

@objc protocol TodoAddCellDelegate {
    @objc optional func todoAddCell(_ todoAddCell: TodoAddCell, todoString: String)
}

class TodoAddCell: UITableViewCell {
    
    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var todoTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    
    weak var delegate: TodoAddCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        todoTextField.placeholder = "Add a follow-up item..."
        configureCellBackgroundView()
        todoTextField.delegate = self
        addButton.tintColor = UIColor.pulseAccentColor()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    // MARK: - Actions
    
    @IBAction func onAddButtonTap(_ sender: UIButton) {
        addTodo()
    }
    
    // MARK: - Helpers
    
    fileprivate func configureCellBackgroundView() {
        cellBackgroundView.layer.cornerRadius = 5.0
        cellBackgroundView.layer.borderWidth = 1.0
        cellBackgroundView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    fileprivate func addTodo() {
        endEditing(true)
        
        if !((todoTextField.text?.isEmpty)!) {
            delegate?.todoAddCell?(self, todoString: todoTextField.text!)
            todoTextField.text = ""
        }
    }
}

extension TodoAddCell: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.becomeFirstResponder()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addTodo()
        return true
    }   
}
