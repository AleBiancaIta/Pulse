//
//  GraphViewController.swift
//  Pulse
//
//  Created by Bianca Curutan on 11/20/16.
//  Copyright © 2016 ABI. All rights reserved.
//

import Parse
import SwiftChart
import UIKit

class LineGraphViewController: UIViewController {
    
    @IBOutlet weak var chartTitleLabel: UILabel!
    
    @IBOutlet weak var chart1: Chart!
    @IBOutlet weak var chart2: Chart!
    @IBOutlet weak var chart3: Chart!
    
    var lineChartLabel1: UILabel?
    var lineChartLabel2: UILabel?
    var lineChartLabel3: UILabel?
    
    var survey1Values: [Float] = []
    var survey2Values: [Float] = []
    var survey3Values: [Float] = []
    var numMonthsAgo: [Float] = []
    var highLowValues = ["Poor", "Good", "Great"]
    
    var personPFObject: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadChartForPerson()
    }
    
    func loadChartForPerson() {
        
        // Reset values
        survey1Values = []
        survey2Values = []
        survey3Values = []
        numMonthsAgo = []
        
        if let personPFObject = personPFObject,
            let personId = personPFObject.objectId {
            let query = PFQuery(className: "Survey")
            query.whereKey("personId", equalTo: personId)
            query.whereKeyDoesNotExist("deletedAt")
            query.order(byAscending: "meetingDate")
            
            // filter by last 6 months
            var pastDate = Date() // this is current date
            pastDate.addTimeInterval((-365/2)*24*60*60) // this is past date now
            query.whereKey("meetingDate", greaterThan: pastDate)
            query.limit = 1000
            
            query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
                if let posts = posts {
                    for post in posts {
                        self.survey1Values.append(post["surveyValueId1"] as! Float)
                        self.survey2Values.append(post["surveyValueId2"] as! Float)
                        self.survey3Values.append(post["surveyValueId3"] as! Float)
                        if let meetingDate = post["meetingDate"] as? Date {
                            self.numMonthsAgo.append(Date.months(from: Date(), to: meetingDate))
                        }
                    }
                    self.setupCharts()
                }
            }
        }
        
        // Initial load (or error, still show empty graph)
        self.setupCharts()
    }
    
    func setupCharts() {
        chart1.backgroundColor = UIColor.clear
        chart2.backgroundColor = UIColor.clear
        chart3.backgroundColor = UIColor.clear
        
        chart1.removeAllSeries()
        chart2.removeAllSeries()
        chart3.removeAllSeries()
        
        // The 3 survey factors should have the same number of data points
        if survey1Values.count > 0 {
            var data1: [(x: Float, y: Float)] = []
            var data2: [(x: Float, y: Float)] = []
            var data3: [(x: Float, y: Float)] = []
            
            for i in 0...survey1Values.count-1 {
                data1.append((x: numMonthsAgo[i], y: survey1Values[i])) // Happiness
                data2.append((x: numMonthsAgo[i], y: survey2Values[i])) // Engagement
                data3.append((x: numMonthsAgo[i], y: survey3Values[i])) // Workload
            }
            
            let survey1Series = ChartSeries(data: data1)
            survey1Series.color = UIColor.pulseAccentColor()
            survey1Series.area = true
            chart1.add(survey1Series)
            chart1.xLabels = [-6, -3, 0]
            chart1.xLabelsFormatter = { String(-Int(round($1))) + " months ago" }
            
            let survey2Series = ChartSeries(data: data2)
            survey2Series.color = UIColor.pulseAccentColor()
            survey2Series.area = true
            chart2.add(survey2Series)
            chart2.xLabels = [-6, -3, 0]
            chart2.xLabelsFormatter = { String(-Int(round($1))) + " months ago" }
            
            let survey3Series = ChartSeries(data: data3)
            survey3Series.color = UIColor.pulseAccentColor()
            survey3Series.area = true
            chart3.add(survey3Series)
            chart3.xLabels = [-6, -3, 0]
            chart3.xLabelsFormatter = { String(-Int(round($1))) + " months ago" }
        }
        
        chart1.labelColor = UIColor.pulseLightPrimaryColor()
        chart1.lineWidth = 2
        chart1.highlightLineColor = UIColor.clear
        chart1.yLabels = [0, 1, 2]
        chart1.yLabelsFormatter = { self.highLowValues[Int($1)] }
        
        chart2.labelColor = UIColor.pulseLightPrimaryColor()
        chart2.lineWidth = 2
        chart2.highlightLineColor = UIColor.clear
        chart2.yLabels = [0, 1, 2]
        chart2.yLabelsFormatter = { self.highLowValues[Int($1)] }
        
        chart3.labelColor = UIColor.pulseLightPrimaryColor()
        chart3.lineWidth = 2
        chart3.highlightLineColor = UIColor.clear
        chart3.yLabels = [0, 1, 2]
        chart3.yLabelsFormatter = { self.highLowValues[Int($1)] }
        
        UIView.animate(withDuration: 1, animations: {
            self.chart1.alpha = 1.0
            self.chart2.alpha = 1.0
            self.chart3.alpha = 1.0
        })
        
        chart1.setNeedsDisplay()
        UIView.transition(with: chart1, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.chart1.layer.displayIfNeeded()
        }, completion: nil)
        
        chart2.setNeedsDisplay()
        UIView.transition(with: chart2, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.chart2.layer.displayIfNeeded()
        }, completion: nil)
        
        chart3.setNeedsDisplay()
        UIView.transition(with: chart3, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.chart3.layer.displayIfNeeded()
        }, completion: nil)
        
        // Setup chart labels (x-axis)
        /*if let personPFObject = personPFObject,
            let firstName = personPFObject["firstName"] as? String {
            
            if lineChartLabel1 != nil {
                UIView.animate(withDuration: 0.5, animations: {
                    self.lineChartLabel1?.alpha = 0
                })
            }
            lineChartLabel1 = UILabel(frame: CGRect(x: 8, y: chart1.frame.origin.y + chart1.frame.size.height - 20, width: chart1.frame.size.width, height: 20))
            lineChartLabel1?.text = survey1Values.count > 0 ? "Pulse for \(firstName)" : "No Pulse data available for \(firstName)"
            lineChartLabel1?.textColor = UIColor.pulseLightPrimaryColor()
            lineChartLabel1?.textAlignment = .center
            lineChartLabel1?.font = lineChartLabel1?.font.withSize(12)
            view.addSubview(lineChartLabel1!)
            UIView.animate(withDuration: 0.5, animations: {
                self.lineChartLabel1?.alpha = 1
            })
            
            if lineChartLabel2 != nil {
                UIView.animate(withDuration: 0.5, animations: {
                    self.lineChartLabel2?.alpha = 0
                })
            }
            lineChartLabel2 = UILabel(frame: CGRect(x: 8, y: chart2.frame.origin.y + chart2.frame.size.height - 20, width: chart2.frame.size.width, height: 20))
            lineChartLabel2?.text = survey2Values.count > 0 ? "Pulse for \(firstName)" : "No Pulse data available for \(firstName)"
            lineChartLabel2?.textColor = UIColor.pulseLightPrimaryColor()
            lineChartLabel2?.textAlignment = .center
            lineChartLabel2?.font = lineChartLabel2?.font.withSize(12)
            view.addSubview(lineChartLabel2!)
            UIView.animate(withDuration: 0.5, animations: {
                self.lineChartLabel2?.alpha = 1
            })
 
            if lineChartLabel3 != nil {
                UIView.animate(withDuration: 0.5, animations: {
                    self.lineChartLabel3?.alpha = 0
                })
            }
            lineChartLabel3 = UILabel(frame: CGRect(x: 8, y: chart3.frame.origin.y + chart3.frame.size.height - 20, width: chart3.frame.size.width, height: 20))
            lineChartLabel3?.text = survey3Values.count > 0 ? "Pulse for \(firstName)" : "No Pulse data available for \(firstName)"
            lineChartLabel3?.textColor = UIColor.pulseLightPrimaryColor()
            lineChartLabel3?.textAlignment = .center
            lineChartLabel3?.font = lineChartLabel3?.font.withSize(12)
            view.addSubview(lineChartLabel3!)
            UIView.animate(withDuration: 0.5, animations: {
                self.lineChartLabel3?.alpha = 1
            })
        }*/
    }
    
    func heightForView() -> CGFloat {
        // Calculated with bottom-most element (y position + height + 8)
        return 296 + 80 + 8
    }
}
