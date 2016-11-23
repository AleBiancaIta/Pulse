//
//  NotesViewController.swift
//  Pulse
//
//  Created by Bianca Curutan on 11/20/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit

protocol NotesViewControllerDelegate: class {
    func notesViewController(notesViewController: NotesViewController, didUpdateNotes notes: String)
}

class NotesViewController: UIViewController {

    @IBOutlet weak var notesTextView: UITextView!
    
    var notes: String?
    weak var delegate: NotesViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notesTextView.delegate = self

        if let notes = notes {
            notesTextView.text = notes
        }
    }
    
    func heightForView() -> CGFloat {
        return 116
    }
}


extension NotesViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        delegate?.notesViewController(notesViewController: self, didUpdateNotes: notesTextView.text)
    }
}
