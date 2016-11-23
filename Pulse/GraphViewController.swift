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
    var diffDaysValues: [Float] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let query = PFQuery(className: "Survey")
        query.whereKey("companyId", equalTo: "Pulse")
        // query.whereKey("meetingDate", lessThanOrEqualTo: ) // TODO <= 30 days ago add to table
        
        query.findObjectsInBackground { (posts: [PFObject]?, error: Error?) in
            if let posts = posts {
                var a: Float = -30 // TODO test
                for post in posts {
                    self.survey1Values.append(post["surveyValueId1"] as! Float)
                    self.survey2Values.append(post["surveyValueId2"] as! Float)
                    self.survey3Values.append(post["surveyValueId3"] as! Float)
                    self.diffDaysValues.append(a) // TODO
                    a += 5
                }
                self.setupCharts()
            }
        }
    }
    
    func setupCharts() {
        chart1.backgroundColor = UIColor.lightGray
        chart2.backgroundColor = UIColor.lightGray
        chart3.backgroundColor = UIColor.lightGray
        
        var data1: [(x: Float, y: Float)] = []
        var data2: [(x: Float, y: Float)] = []
        var data3: [(x: Float, y: Float)] = []
        for i in 0...diffDaysValues.count-1 {
            data1.append((x: diffDaysValues[i], y: survey1Values[i])) // Happiness
            data2.append((x: diffDaysValues[i], y: survey2Values[i])) // Engagement
            data3.append((x: diffDaysValues[i], y: survey3Values[i])) // Workload
        }

        let survey1Series = ChartSeries(data: data1)
        survey1Series.color = UIColor.blue
        survey1Series.area = true
        chart1.add(survey1Series)
        chart1.xLabels = [-30, -20, -10, 0]
        chart1.xLabelsFormatter = { String(Int(round($1))) + " days" }
        chart1.yLabels = [0, 1, 2]
        
        let survey2Series = ChartSeries(data: data2)
        survey2Series.color = UIColor.red
        survey2Series.area = true
        chart2.add(survey2Series)
        chart2.xLabels = [-30, -20, -10, 0]
        chart2.xLabelsFormatter = { String(Int(round($1))) + " days" }
        chart2.yLabels = [0, 1, 2]

        let survey3Series = ChartSeries(data: data3)
        survey3Series.color = UIColor.green
        survey3Series.area = true
        chart3.add(survey3Series)
        chart3.xLabels = [-30, -20, -10, 0]
        chart3.xLabelsFormatter = { String(Int(round($1))) + " days" }
        chart3.yLabels = [0, 1, 2]
    }

    func heightForView() -> CGFloat {
        return 375 // TODO
    }

}
