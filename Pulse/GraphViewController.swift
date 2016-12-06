//
//  GraphViewController.swift
//  Pulse
//
//  Created by Bianca Curutan on 11/20/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import Parse
import DSBarChart
import UIKit
import HMSegmentedControl

class GraphViewController: UIViewController {

    @IBOutlet weak var chartTitleLabel: UILabel!
    
    @IBOutlet weak var chart1: UIView!
    @IBOutlet weak var chart2: UIView!
    @IBOutlet weak var chart3: UIView!
    
    //@IBOutlet weak var chartSegmentedControl: UISegmentedControl!
    
    var barChart1: DSBarChart?
    var barChart2: DSBarChart?
    var barChart3: DSBarChart?
    var barChartLabel1: UILabel?
    var barChartLabel2: UILabel?
    var barChartLabel3: UILabel?
    
    var survey1Values: [Float] = []
    var survey2Values: [Float] = []
    var survey3Values: [Float] = []
    var personIdValues: [String] = []
    var highLowValues = ["Poor", "Good", "Great"]
    
    var teamMemberIds = [String]()
    var isCompany = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //chartSegmentedControl.layer.cornerRadius = 5
        loadChartForCompany()
        configureCustomSegmentedControl()
    }
    
    fileprivate func configureCustomSegmentedControl() {
        let control = HMSegmentedControl(sectionTitles: ["Team", "Company"])
        control?.frame = CGRect(x: 180, y: 9, width: 180, height: 30)
        control?.backgroundColor = UIColor.clear
        control?.selectionIndicatorLocation = .down
        control?.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.pulseLightPrimaryColor(), NSFontAttributeName : UIFont(name: "Helvetica Neue", size: 16.0)!]
        control?.selectedTitleTextAttributes = [NSForegroundColorAttributeName: UIColor.pulseAccentColor()]
        control?.selectionStyle = .fullWidthStripe
        control?.selectionIndicatorHeight = 1.5
        control?.selectionIndicatorColor = UIColor.pulseAccentColor()
        control?.addTarget(self, action: #selector(onControlChange(_:)), for: UIControlEvents.valueChanged)
        self.view.addSubview(control!)
    }
    
    // isCompany == true, load chart for whole company
    // isCompany == false, load chart for my team only
    func loadChartForCompany() {
        
        // Reset values
        personIdValues = []
        survey1Values = []
        survey2Values = []
        survey3Values = []
        
        if isCompany {
            ParseClient.sharedInstance().getCurrentPerson { (person: PFObject?, error: Error?) in
                if let person = person {
                    let query = PFQuery(className: "Survey")
                    query.whereKey("companyId", equalTo: person["companyId"])
                    
                    // filter by last 30 days
                    var pastDate = Date() // this is current date
                    pastDate.addTimeInterval(-30*24*60*60)
                    query.whereKey("meetingDate", greaterThan: pastDate)
                    query.order(byDescending: "meetingDate")
                    query.limit = 1000
                    
                    query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
                        if let posts = posts {
                            for post in posts {
                                if let personId = post["personId"] as? String {
                                    if !self.personIdValues.contains(personId) {
                                        self.survey1Values.append(post["surveyValueId1"] as! Float)
                                        self.survey2Values.append(post["surveyValueId2"] as! Float)
                                        self.survey3Values.append(post["surveyValueId3"] as! Float)
                                        self.personIdValues.append(personId)
                                    }
                                }
                            }
                            self.setupCharts()
                        }
                    }
                }
            }
        } else { // Team
            ParseClient.sharedInstance().getCurrentPerson { (person: PFObject?, error: Error?) in
                if let person = person {
                    let query = PFQuery(className: "Survey")
                    query.whereKey("companyId", equalTo: person["companyId"])
                    
                    // filter by last 30 days
                    var pastDate = Date() // this is current date
                    pastDate.addTimeInterval(-30*24*60*60)
                    query.whereKey("meetingDate", greaterThan: pastDate)
                    query.order(byDescending: "meetingDate")
                    query.limit = 1000
                    
                    query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
                        if let posts = posts {
                            ParseClient.sharedInstance().fetchTeamMembersFor(managerId: person.objectId!, isAscending1: true, isAscending2: nil, orderBy1: ObjectKeys.Person.lastName, orderBy2: nil, isDeleted: false) { (members: [PFObject]?, error: Error?) in
                                if let error = error {
                                    print(error.localizedDescription)
                                } else {
                                    //debugPrint("in graph, members: \(members)")
                                    if let members = members, members.count > 0 {
                                        for member in members {
                                            if let personId = member.objectId,
                                                !self.teamMemberIds.contains(personId) {
                                                self.teamMemberIds.append(personId)
                                            }
                                        }
                                        //debugPrint("in graph, teamMemberIds: \(self.teamMemberIds)")
                                        
                                        for post in posts {
                                            if let personId = post["personId"] as? String {
                                                //debugPrint("in graph, personId: \(personId)")
                                                if !self.personIdValues.contains(personId) &&
                                                    self.teamMemberIds.contains(personId) {
                                                    self.survey1Values.append(post["surveyValueId1"] as! Float)
                                                    self.survey2Values.append(post["surveyValueId2"] as! Float)
                                                    self.survey3Values.append(post["surveyValueId3"] as! Float)
                                                    self.personIdValues.append(personId)
                                                }
                                            }
                                        }
                                        //debugPrint("personIdValues: \(self.personIdValues)")
                                        self.setupCharts()
                                    } else {
                                        debugPrint("Fetch members returned 0 members")
                                        self.setupCharts()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        // Initial load (or error, still show empty graph)
        //self.setupCharts()
    }
    
    func setupCharts() {
        var vals1: [Float] = [] // Values
        var vals2: [Float] = [] // Values
        var vals3: [Float] = [] // Values
        var refs: [String] = [] // References, doesn't actually do anything in our case
        
        //let vals = [2, 1, 3, 2, 3, 1, 1, 2, 3, 1, 1, 2, 2, 2]
        //let refs = ["M", "T", "W", "Th", "F", "S", "Su", "M", "T", "W", "Th", "F", "S", "Su"]

        if personIdValues.count > 0 {
            for i in 0...personIdValues.count-1 {
                vals1.append(survey1Values[i] + 1) // Happiness
                vals2.append(survey2Values[i] + 1) // Engagement
                vals3.append(survey3Values[i] + 1) // Workload
                refs.append("")
            }
        }
        
        // Setup chart views
        if barChart1 != nil {
            UIView.animate(withDuration: 0.5, animations: {
                self.barChart1?.alpha = 0
            })
        }
        barChart1 = DSBarChart.init(frame: chart1.bounds, color: UIColor.pulseLightPrimaryColor(), references: refs, andValues: vals1)
        barChart1?.backgroundColor = UIColor.clear
        barChart1?.frame.origin.y = chart1.frame.origin.y
        barChart1?.alpha = 0
        view.addSubview(barChart1!)
        UIView.animate(withDuration: 0.5, animations: {
            self.barChart1?.alpha = 1
        })
        
        if barChart2 != nil {
            UIView.animate(withDuration: 0.5, animations: {
                self.barChart2?.alpha = 0
            })
        }
        barChart2 = DSBarChart.init(frame: chart2.bounds, color: UIColor.pulseLightPrimaryColor(), references: refs, andValues: vals2)
        barChart2?.backgroundColor = UIColor.clear
        barChart2?.frame.origin.y = chart2.frame.origin.y
        barChart2?.alpha = 0
        view.addSubview(barChart2!)
        UIView.animate(withDuration: 0.5, animations: {
            self.barChart2?.alpha = 1
        })
        
        if barChart3 != nil {
            UIView.animate(withDuration: 0.5, animations: {
                self.barChart3?.alpha = 0
            })
        }
        barChart3 = DSBarChart.init(frame: chart3.bounds, color: UIColor.pulseLightPrimaryColor(), references: refs, andValues: vals3)
        barChart3?.backgroundColor = UIColor.clear
        barChart3?.frame.origin.y = chart3.frame.origin.y
        barChart3?.alpha = 0
        view.addSubview(barChart3!)
        UIView.animate(withDuration: 0.5, animations: {
            self.barChart3?.alpha = 1
        })
        
        // Setup chart labels (x-axis)
        if barChartLabel1 != nil {
            UIView.animate(withDuration: 0.5, animations: {
                self.barChartLabel1?.alpha = 0
            })
        }
        barChartLabel1 = UILabel(frame: CGRect(x: 8, y: chart1.frame.origin.y + chart1.frame.size.height - 20, width: chart1.frame.size.width, height: 20))
        barChartLabel1?.text = vals1.count > 0 ? "Pulse for \(vals1.count) employees" : "No Pulse data available"
        barChartLabel1?.textColor = UIColor.pulseLightPrimaryColor()
        barChartLabel1?.textAlignment = .center
        barChartLabel1?.font = barChartLabel1?.font.withSize(12)
        view.addSubview(barChartLabel1!)
        UIView.animate(withDuration: 0.5, animations: {
            self.barChartLabel1?.alpha = 1
        })
        
        if barChartLabel2 != nil {
            UIView.animate(withDuration: 0.5, animations: {
                self.barChartLabel2?.alpha = 0
            })
        }
        barChartLabel2 = UILabel(frame: CGRect(x: 8, y: chart2.frame.origin.y + chart2.frame.size.height - 20, width: chart2.frame.size.width, height: 20))
        barChartLabel2?.text = vals2.count > 0 ? "Pulse for \(vals2.count) employees" : "No Pulse data available"
        barChartLabel2?.textColor = UIColor.pulseLightPrimaryColor()
        barChartLabel2?.textAlignment = .center
        barChartLabel2?.font = barChartLabel2?.font.withSize(12)
        view.addSubview(barChartLabel2!)
        UIView.animate(withDuration: 0.5, animations: {
            self.barChartLabel2?.alpha = 1
        })
        
        if barChartLabel3 != nil {
            UIView.animate(withDuration: 0.5, animations: {
                self.barChartLabel3?.alpha = 0
            })
        }
        barChartLabel3 = UILabel(frame: CGRect(x: 8, y: chart3.frame.origin.y + chart3.frame.size.height - 20, width: chart3.frame.size.width, height: 20))
        barChartLabel3?.text = vals3.count > 0 ? "Pulse for \(vals3.count) employees" : "No Pulse data available"
        barChartLabel3?.textColor = UIColor.pulseLightPrimaryColor()
        barChartLabel3?.textAlignment = .center
        barChartLabel3?.font = barChartLabel3?.font.withSize(12)
        view.addSubview(barChartLabel3!)
        UIView.animate(withDuration: 0.5, animations: {
            self.barChartLabel3?.alpha = 1
        })
    }

    func heightForView() -> CGFloat {
        // Calculated with bottom-most element (y position + height + 8)
        return 296 + 80 + 8
    }

    /*
    @IBAction func onSegmentedControlChange(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            isCompany = false
            loadChartForCompany()
        case 1:
            isCompany = true
            loadChartForCompany()
        default:
            break
        }
    }*/
    
    @objc func onControlChange(_ sender: HMSegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            isCompany = false
            loadChartForCompany()
        case 1:
            isCompany = true
            loadChartForCompany()
        default:
            break
        }
    }
    
}
