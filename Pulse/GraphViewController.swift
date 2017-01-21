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
import DYPieChartView

class GraphViewController: UIViewController {

    @IBOutlet weak var chartTitleLabel: UILabel!
    
    @IBOutlet weak var chart1: UIView!
    @IBOutlet weak var chart2: UIView!
    @IBOutlet weak var chart3: UIView!
    
    var barChart1: DSBarChart?
    var barChart2: DSBarChart?
    var barChart3: DSBarChart?
    var barChartLabel1: UILabel?
    var barChartLabel2: UILabel?
    var barChartLabel3: UILabel?
    
    var pieChart1: DYPieChartView?
    var pieChart2: DYPieChartView?
    var pieChart3: DYPieChartView?
    var pieChartLabel1: UILabel?
    var pieChartLabel2: UILabel?
    var pieChartLabel3: UILabel?
    
    var survey1Values: [Float] = []
    var survey2Values: [Float] = []
    var survey3Values: [Float] = []
    var personIdValues: [String] = []
    var highLowValues = ["Poor", "Good", "Great"]
    
    var teamMemberIds: [String] = []
    var isCompany = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCustomSegmentedControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //chartSegmentedControl.layer.cornerRadius = 5
        loadDataForCharts()
    }
    
    fileprivate func configureCustomSegmentedControl() {
        let control = HMSegmentedControl(sectionTitles: ["Team", "Company"])
        let originX = UIScreen.main.bounds.width - 180 - 8
        control?.frame = CGRect(x: originX, y: 9, width: 180, height: 30)
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
    func loadDataForCharts() {
        
        // Reset values
        personIdValues = []
        survey1Values = []
        survey2Values = []
        survey3Values = []
        teamMemberIds = []
        
        if isCompany {
            ParseClient.sharedInstance().getCurrentPerson { (person: PFObject?, error: Error?) in
                if let person = person {
                    let query = PFQuery(className: "Survey")
                    query.whereKey("companyId", equalTo: person["companyId"])
                    query.whereKeyDoesNotExist("deletedAt")
                    
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
                            self.setupPieCharts()
                        }
                    }
                }
            }
        } else { // Team
            ParseClient.sharedInstance().getCurrentPerson { (person: PFObject?, error: Error?) in
                if let person = person {
                    let query = PFQuery(className: "Survey")
                    query.whereKey("companyId", equalTo: person["companyId"])
                    query.whereKeyDoesNotExist("deletedAt")
                    
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
                                        self.setupBarCharts()
                                    } else {
                                        debugPrint("Fetch members returned 0 members")
                                        self.setupBarCharts()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func setupPieCharts() {
        // Hide team charts and labels
        UIView.animate(withDuration: 0.5, animations: {
            self.barChart1?.alpha = 0
            self.barChart2?.alpha = 0
            self.barChart3?.alpha = 0
            self.barChartLabel1?.alpha = 0
            self.barChartLabel2?.alpha = 0
            self.barChartLabel3?.alpha = 0
        })
        
        // Setup data
        var vals1Bad = 0.0
        var vals1Neutral = 0.0
        var vals1Good = 0.0
        var vals2Bad = 0.0
        var vals2Neutral = 0.0
        var vals2Good = 0.0
        var vals3Bad = 0.0
        var vals3Neutral = 0.0
        var vals3Good = 0.0
        if personIdValues.count > 0 {
            for i in 0...personIdValues.count-1 {
                // Happiness
                if survey1Values[i] == 0 {
                    vals1Bad += 1
                } else if survey1Values[i] == 1 {
                    vals1Neutral += 1
                } else if survey1Values[i] == 2 {
                    vals1Good += 1
                }
                // Engagement
                if survey2Values[i] == 0 {
                    vals2Bad += 1
                } else if survey2Values[i] == 1 {
                    vals2Neutral += 1
                } else if survey2Values[i] == 2 {
                    vals2Good += 1
                }
                // Workload
                if survey3Values[i] == 0 {
                    vals3Bad += 1
                } else if survey3Values[i] == 1 {
                    vals3Neutral += 1
                } else if survey3Values[i] == 2 {
                    vals3Good += 1
                }
            }
        }
        let scale1Bad = vals1Bad/Double(personIdValues.count)
        let scale1Neutral = vals1Neutral/Double(personIdValues.count)
        let scale1Good = vals1Good/Double(personIdValues.count)
        let scale2Bad = vals2Bad/Double(personIdValues.count)
        let scale2Neutral = vals2Neutral/Double(personIdValues.count)
        let scale2Good = vals2Good/Double(personIdValues.count)
        let scale3Bad = vals3Bad/Double(personIdValues.count)
        let scale3Neutral = vals3Neutral/Double(personIdValues.count)
        let scale3Good = vals3Good/Double(personIdValues.count)
        
        // Setup charts
        if pieChart1 != nil {
            UIView.animate(withDuration: 0.5, animations: {
                self.pieChart1?.alpha = 0
            })
        }
        pieChart1 = DYPieChartView.init(frame: CGRect(x: chart1.bounds.origin.x - 8, y: chart1.bounds.origin.y, width: chart1.bounds.size.height, height: chart1.bounds.size.height))
        pieChart1?.backgroundColor = UIColor.clear
        pieChart1?.sectorColors = [UIColor.pulseBadSurveyColor(), UIColor.pulseNeutralSurveyColor(), UIColor.pulseGoodSurveyColor()]
        pieChart1?.center = CGPoint(x: chart1.bounds.size.height, y: chart1.center.y)
        pieChart1?.alpha = 0
        view.addSubview(pieChart1!)
        UIView.animate(withDuration: 0.5, animations: {
            self.pieChart1?.alpha = 1
        })
        pieChart1?.animate(toScaleValues: [scale1Bad, scale1Neutral, scale1Good], duration: 0.5)
        
        if pieChart2 != nil {
            UIView.animate(withDuration: 0.5, animations: {
                self.pieChart2?.alpha = 0
            })
        }
        pieChart2 = DYPieChartView.init(frame: CGRect(x: chart2.bounds.origin.x - 8, y: chart2.bounds.origin.y, width: chart2.bounds.size.height, height: chart2.bounds.size.height))
        pieChart2?.backgroundColor = UIColor.clear
        pieChart2?.sectorColors = [UIColor.pulseBadSurveyColor(), UIColor.pulseNeutralSurveyColor(), UIColor.pulseGoodSurveyColor()]
        pieChart2?.center = CGPoint(x: chart2.bounds.size.height, y: chart2.center.y)
        pieChart2?.alpha = 0
        view.addSubview(pieChart2!)
        UIView.animate(withDuration: 0.5, animations: {
            self.pieChart2?.alpha = 1
        })
        pieChart2?.animate(toScaleValues: [scale2Bad, scale2Neutral, scale2Good], duration: 0.5)
        
        if pieChart3 != nil {
            UIView.animate(withDuration: 0.5, animations: {
                self.pieChart3?.alpha = 0
            })
        }
        pieChart3 = DYPieChartView.init(frame: CGRect(x: chart3.bounds.origin.x - 8, y: chart3.bounds.origin.y, width: chart3.bounds.size.height, height: chart3.bounds.size.height))
        pieChart3?.backgroundColor = UIColor.clear
        pieChart3?.sectorColors = [UIColor.pulseBadSurveyColor(), UIColor.pulseNeutralSurveyColor(), UIColor.pulseGoodSurveyColor()]
        pieChart3?.center = CGPoint(x: chart3.bounds.size.height, y: chart3.center.y)
        pieChart3?.alpha = 0
        view.addSubview(pieChart3!)
        UIView.animate(withDuration: 0.5, animations: {
            self.pieChart3?.alpha = 1
        })
        pieChart3?.animate(toScaleValues: [scale3Bad, scale3Neutral, scale3Good], duration: 0.5)
        
        // Setup labels
        let s = vals1Bad > 1 || vals1Neutral > 1 || vals1Good > 1 ? "s" : ""
        let scale1BadString = String(format: "%.1f", scale1Bad * 100)
        let scale1NeutralString = String(format: "%.1f", scale1Neutral * 100)
        let scale1GoodString = String(format: "%.1f", scale1Good * 100)
        let scale2BadString = String(format: "%.1f", scale2Bad * 100)
        let scale2NeutralString = String(format: "%.1f", scale2Neutral * 100)
        let scale2GoodString = String(format: "%.1f", scale2Good * 100)
        let scale3BadString = String(format: "%.1f", scale3Bad * 100)
        let scale3NeutralString = String(format: "%.1f", scale3Neutral * 100)
        let scale3GoodString = String(format: "%.1f", scale3Good * 100)
        
        if pieChartLabel1 != nil {
            UIView.animate(withDuration: 0.5, animations: {
                self.pieChartLabel1?.alpha = 0
            })
        }
        pieChartLabel1 = UILabel(frame: CGRect(x: chart1.bounds.size.height * 1.8, y: chart1.frame.origin.y, width: 200, height: 80))
        pieChartLabel1?.text = vals1Bad > 0 || vals1Neutral > 0 || vals1Good > 0 ? "Pulse for \(personIdValues.count) employee\(s)\n\(scale1BadString)% Poor\n\(scale1NeutralString)% Good\n\(scale1GoodString)% Great" : "No Pulse data available"
        pieChartLabel1?.textColor = UIColor.pulseLightPrimaryColor()
        pieChartLabel1?.numberOfLines = 0
        pieChartLabel1?.font = pieChartLabel1?.font.withSize(12)
        view.addSubview(pieChartLabel1!)
        UIView.animate(withDuration: 0.5, animations: {
            self.pieChartLabel1?.alpha = 1
        })

        if pieChartLabel2 != nil {
            UIView.animate(withDuration: 0.5, animations: {
                self.pieChartLabel2?.alpha = 0
            })
        }
        pieChartLabel2 = UILabel(frame: CGRect(x: chart2.bounds.size.height * 1.8, y: chart2.frame.origin.y, width: 200, height: 80))
        pieChartLabel2?.text = vals2Bad > 0 || vals2Neutral > 0 || vals2Good > 0 ? "Pulse for \(personIdValues.count) employee\(s)\n\(scale2BadString)% Poor\n\(scale2NeutralString)% Good\n\(scale2GoodString)% Great" : "No Pulse data available"
        pieChartLabel2?.textColor = UIColor.pulseLightPrimaryColor()
        pieChartLabel2?.numberOfLines = 0
        pieChartLabel2?.font = pieChartLabel2?.font.withSize(12)
        view.addSubview(pieChartLabel2!)
        UIView.animate(withDuration: 0.5, animations: {
            self.pieChartLabel2?.alpha = 1
        })
        
        if pieChartLabel3 != nil {
            UIView.animate(withDuration: 0.5, animations: {
                self.pieChartLabel3?.alpha = 0
            })
        }
        pieChartLabel3 = UILabel(frame: CGRect(x: chart3.bounds.size.height * 1.8, y: chart3.frame.origin.y, width: 200, height: 80))
        pieChartLabel3?.text = vals3Bad > 0 || vals3Neutral > 0 || vals3Good > 0 ? "Pulse for \(personIdValues.count) employee\(s)\n\(scale3BadString)% Poor\n\(scale3NeutralString)% Good\n\(scale3GoodString)% Great" : "No Pulse data available"
        pieChartLabel3?.textColor = UIColor.pulseLightPrimaryColor()
        pieChartLabel3?.numberOfLines = 0
        pieChartLabel3?.font = pieChartLabel3?.font.withSize(12)
        view.addSubview(pieChartLabel3!)
        UIView.animate(withDuration: 0.5, animations: {
            self.pieChartLabel3?.alpha = 1
        })
    }
    
    func setupBarCharts() {
        // Hide company charts and labels
        UIView.animate(withDuration: 0.5, animations: {
            self.pieChart1?.alpha = 0
            self.pieChart2?.alpha = 0
            self.pieChart3?.alpha = 0
            self.pieChartLabel1?.alpha = 0
            self.pieChartLabel2?.alpha = 0
            self.pieChartLabel3?.alpha = 0
        })
        
        var vals1: [Float] = [] // Values
        var vals2: [Float] = [] // Values
        var vals3: [Float] = [] // Values
        var refs: [String] = [] // References, doesn't actually do anything in our case
        
        if personIdValues.count > 0 {
            for i in 0...personIdValues.count-1 {
                // +1 so all 3 values show up in the graph (no 0s)
                vals1.append(survey1Values[i] + 1) // Happiness
                vals2.append(survey2Values[i] + 1) // Engagement
                vals3.append(survey3Values[i] + 1) // Workload
                refs.append("")
            }
        }
        
        // Sort values from low to high
        /*vals1.sort()
        vals2.sort()
        vals3.sort()*/
        
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
        let s = vals1.count > 1 ? "s" : "" // Shouldn't matter which vals1 is used since should be vals1.count == vals2.count == vals3.count
        
        if barChartLabel1 != nil {
            UIView.animate(withDuration: 0.5, animations: {
                self.barChartLabel1?.alpha = 0
            })
        }
        barChartLabel1 = UILabel(frame: CGRect(x: 8, y: chart1.frame.origin.y + chart1.frame.size.height - 20, width: chart1.frame.size.width, height: 20))
        barChartLabel1?.text = vals1.count > 0 ? "Pulse for \(vals1.count) employee\(s)" : "No Pulse data available"
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
        barChartLabel2?.text = vals2.count > 0 ? "Pulse for \(vals2.count) employee\(s)" : "No Pulse data available"
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
        barChartLabel3?.text = vals3.count > 0 ? "Pulse for \(vals3.count) employee\(s)" : "No Pulse data available"
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

    @objc func onControlChange(_ sender: HMSegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            isCompany = false
            loadDataForCharts()
        case 1:
            isCompany = true
            loadDataForCharts()
        default:
            break
        }
    }
    
}
