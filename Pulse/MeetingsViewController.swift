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
        
        self.title = "Meetings"

        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UINib(nibName: "MessageCellNib", bundle: nil), forCellReuseIdentifier: "MessageCell")
        
        ParseClient.sharedInstance().getCurrentPerson { (person: PFObject?, error: Error?) in
            if let person = person {
                
                let query = PFQuery(className: "Meetings")
                let managerId = person["userId"] as! String
                query.whereKey("managerId", equalTo: managerId)
                
                query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
                    if let posts = posts {
                        
                        for post in posts {
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            if let meetingDateString = post["meetingDate"] as? String,
                                let meetingDate = dateFormatter.date(from: meetingDateString) {
                                let dictionary = [
                                    "personId": post["personId"],
                                    "managerId": post["managerId"],
                                    "surveyId": post["surveyId"],
                                    "meetingDate": meetingDate
                                ]
                                
                                let meeting = Meeting(dictionary: dictionary)
                                self.meetings.append(meeting)
                            }
                            
                            if let meetingDate = post["meetingDate"] as? Date {
                                let dictionary = [
                                    "personId": post["personId"],
                                    "managerId": post["managerId"],
                                    "surveyId": post["surveyId"],
                                    "meetingDate": meetingDate
                                ]
                                
                                let meeting = Meeting(dictionary: dictionary)
                                self.meetings.append(meeting)
                            }
                        }
                        
                        self.tableView.reloadData()
                        
                    } else {
                        print(error?.localizedDescription)
                    }
                }
            }
        }
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
            cell.messageLabel.text = "No meetings"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (0 < meetings.count ? meetings.count : 1)
    }
}

extension MeetingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect row appearance after it has been selected
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
