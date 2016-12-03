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

class GraphViewController: UIViewController {

    @IBOutlet weak var chart1: Chart!
    @IBOutlet weak var chart2: Chart!
    @IBOutlet weak var chart3: Chart!
    
    var survey1Values: [Float] = []
    var survey2Values: [Float] = []
    var survey3Values: [Float] = []
    var personIdValues: [String] = []
    var highLowValues = ["Poor", "Good", "Great"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let query = PFQuery(className: "Survey")
        query.whereKey("companyId", equalTo: "Pulse")
        
        // filter by last 30 days
        var pastDate = Date() // this is current date
        pastDate.addTimeInterval(-30*24*60*60)
        query.whereKey("meetingDate", greaterThan: pastDate)
        
        query.order(byDescending: "meetingDate") // TODO
        
        
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
    
    func setupCharts() {
        chart1.backgroundColor = UIColor.clear
        chart2.backgroundColor = UIColor.clear
        chart3.backgroundColor = UIColor.clear
        
        if personIdValues.count > 0 {
            var data1: [(x: Float, y: Float)] = []
            var data2: [(x: Float, y: Float)] = []
            var data3: [(x: Float, y: Float)] = []
            
            for i in 0...personIdValues.count-1 {
                data1.append((x: Float(i), y: survey1Values[i])) // Happiness
                data2.append((x: Float(i), y: survey2Values[i])) // Engagement
                data3.append((x: Float(i), y: survey3Values[i])) // Workload
            }
            
            let survey1Series = ChartSeries(data: data1)
            survey1Series.color = UIColor.pulseAccentColor()
            survey1Series.area = true
            chart1.add(survey1Series)
            chart1.xLabels = [0, Float(data1.count-1)]
            
            let survey2Series = ChartSeries(data: data2)
            survey2Series.color = UIColor.pulseAccentColor()
            survey2Series.area = true
            chart2.add(survey2Series)
            chart2.xLabels = [0, Float(data2.count-1)]
            
            let survey3Series = ChartSeries(data: data3)
            survey3Series.color = UIColor.pulseAccentColor()
            survey3Series.area = true
            chart3.add(survey3Series)
            chart3.xLabels = [0, Float(data3.count-1)]
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
    }

    func heightForView() -> CGFloat {
        // Calculated with bottom-most element (y position + height + 8)
        return 282 + 80 + 8
    }

}
