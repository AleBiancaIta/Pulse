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
    
    @IBOutlet weak var draftLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    
    var notes: String?
    weak var delegate: NotesViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notesTextView.delegate = self
        notesTextView.layer.cornerRadius = 5
        notesTextView.layer.borderWidth = 1
        notesTextView.layer.borderColor = UIColor.pulseLightPrimaryColor().cgColor

        if let notes = notes {
            notesTextView.text = notes
        }
    }
    
    func heightForView() -> CGFloat {
        // Calculated with bottom-most element (y position + height + 8)
        return 54 + 80 
    }
    
    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        self.notesTextView.resignFirstResponder()
    }
}

// MARK: - UITextViewDelegate

extension NotesViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        draftLabel.isHidden = false
        delegate?.notesViewController(notesViewController: self, didUpdateNotes: notesTextView.text)
    }
}

// MARK: - MeetingDetailsViewControllerDelegate

extension NotesViewController: MeetingDetailsViewControllerDelegate {
     func meetingDetailsViewController(_ meetingDetailsViewController: MeetingDetailsViewController, onSave: Bool) {
        draftLabel.isHidden = true
    }
}
