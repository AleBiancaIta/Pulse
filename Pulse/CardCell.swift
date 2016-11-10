//
//  CardCell.swift
//  Pulse
//
//  Created by Bianca Curutan on 11/10/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit

protocol CardCellDelegate: class {
    func cardCell(cardCell: CardCell, didMoveUp card: Card)
    func cardCell(cardCell: CardCell, didMoveDown card: Card)
    func cardCell(cardCell: CardCell, didDelete card: Card)
}

class CardCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    weak var delegate: CardCellDelegate?
    
    var card: Card! {
        didSet {
            titleLabel.text = card.name
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func onUpButton(_ sender: AnyObject) {
        print("up")
        delegate?.cardCell(cardCell: self, didMoveUp: card)
    }

    @IBAction func onDownButton(_ sender: AnyObject) {
        print("down")
        delegate?.cardCell(cardCell: self, didMoveDown: card)
    }
    
    @IBAction func onDeleteButton(_ sender: AnyObject) {
        print("delete")
        delegate?.cardCell(cardCell: self, didDelete: card)
    }
}
