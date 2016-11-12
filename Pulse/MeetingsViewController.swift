//
//  MeetingsViewController.swift
//  Pulse
//
//  Created by Bianca Curutan on 11/11/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import UIKit

class MeetingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var meetings: [Meeting] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        meetings = Constants.meetings // TODO fix this to pull from parse
        
        tableView.register(UINib(nibName: "MessageCellNib", bundle: nil), forCellReuseIdentifier: "MessageCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func heightForView() -> CGFloat {
        return CGFloat(self.tableView(tableView, numberOfRowsInSection: 0) * 44)
    }
}

extension MeetingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
        if 0 < meetings.count {
            if let personName = meetings[indexPath.row].personName,
                let meetingDate = meetings[indexPath.row].meetingDate {
                cell.messageLabel.text = "\(personName) (\(meetingDate))"
            }
        } else {
            cell.messageLabel.text = "No upcoming meetings"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (0 < meetings.count ? meetings.count : 1)
    }
}

extension MeetingsViewController: UITableViewDelegate {
    
}
