//
//  MeetingsViewController.swift
//  Pulse
//
//  Created by Bianca Curutan on 11/11/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import Parse
import UIKit

class MeetingsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var meetings: [Meeting] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UINib(nibName: "MessageCellNib", bundle: nil), forCellReuseIdentifier: "MessageCell")
        
        let query = PFQuery(className: "Meetings")
        query.whereKey("managerId", equalTo: "xyz") // TODO logged in casePFUser.current()?.objectId
        //query.whereKey("meetingDate", equalTo: "2016-12-01")
        
        query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
            if let posts = posts {
                //TODO - remove below also... self.meetings = Meeting.meetingsWithArray(dictionaries: posts)
                
                let post = posts[0]
                
                let dateFormatter = DateFormatter()
                // dateFormatter.dateFormat =
                let meetingDate = dateFormatter.date(from: post["meetingDate"] as! String)
                
                if let meetingDate = meetingDate {
                    let dictionary = [
                        "personId": post["personId"],
                        "managerId": post["managerId"],
                        "surveyId": post["surveyId"],
                        "meetingDate": meetingDate
                    ]
                    
                    let meeting = Meeting(dictionary: dictionary)
                    self.meetings.append(meeting)
                }
                // end TODO remove
                
                self.tableView.reloadData()
                
            } else {
                print(error?.localizedDescription)
            }
        }
    }
    
    func heightForView() -> CGFloat {
        return CGFloat(3*44) //CGFloat(self.tableView(tableView, numberOfRowsInSection: 0) * 44)
    }
}

extension MeetingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
        if 0 < meetings.count {
            let personId = meetings[indexPath.row].personId // TODO should be person name
            let meetingDate = meetings[indexPath.row].meetingDate
            cell.messageLabel.text = "\(personId) (\(meetingDate))"

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
