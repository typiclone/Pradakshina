//
//  Analytics.swift
//  Pradakshina
//
//  Created by Vasisht Muduganti on 9/17/24.
//

import UIKit
import Charts
import SwiftUI

class Analytics: UIViewController {
    
    let defaults = UserDefaults.standard
    var dailyLaps = 0
    var weeklyLaps = 0
    var totalLaps = 0
    
    var dailyTimes = 0
    var weeklyTimes = 0
    
    
    var dailyTimesHeading:UILabel?
    var dailyTimesSubheading:UILabel?
    
    var weeklyTimesHeading:UILabel?
    var weeklyTimesSubheading:UILabel?
    
    
    override func viewWillAppear(_ animated: Bool) {
        updateValues()
    }
    var dailyLapsHeading:UILabel?
    var dailyLapsSubheading:UILabel?
    
    var weeklyLapsHeading:UILabel?
    var weeklyLapsSubheading:UILabel?
    
    var totalLapsHeading:UILabel?
    var totalLapsSubheading:UILabel?
    func updateValues(){
        
        dailyLaps = defaults.integer(forKey: "dailyLaps")
        weeklyLaps = defaults.integer(forKey: "weeklyLaps")
        totalLaps = defaults.integer(forKey: "totalLaps")
        
        dailyLapsSubheading?.text = "\(dailyLaps)"
        weeklyLapsSubheading?.text = "\(weeklyLaps)"
        totalLapsSubheading?.text = "\(totalLaps)"
        
        var list = [LapModel]()
        var daysInorder = [String]()
        var startDay = defaults.integer(forKey: "startDay")
        lapArray = defaults.array(forKey: "lapArray") as? [Int]
        timeArray = defaults.array(forKey: "timeArray") as? [Int]
        var currentDay = dayEnumerated2[Date().dayOfWeek()!]
        if currentDay! >= startDay{
            dailyTimes = timeArray![currentDay! - startDay]
            dailyTimes /= max(1,lapArray![currentDay! - startDay])
        }
        else{
            dailyTimes = timeArray![7 - startDay + currentDay!]
            dailyTimes /= max(1,lapArray![7 - startDay + currentDay!])
        }
        var lapCount = 0
        var timeCount = 0
        for i in 0...6{
            lapCount += lapArray![i]
            timeCount += timeArray![i]
        }
        weeklyTimes = timeCount/max(1,lapCount)
        
        dailyTimesSubheading?.text = "\(formatTime(seconds: dailyTimes))"
        weeklyTimesSubheading?.text = "\(formatTime(seconds: weeklyTimes))"
        
        //print("quasmo \(lapArray)")
        //print()
        for i in startDay...7{
            daysInorder.append(String(dayEnumerated[i]!.prefix(3)))
        }
        for i in 1..<startDay{
            daysInorder.append(String(dayEnumerated[i]!.prefix(3)))
        }
        
        for i in 0..<daysInorder.count{
            list.append(LapModel(day: daysInorder[i], timeInSeconds: timeArray![i], lapCount: lapArray![i]))
        }
        displayedList = list
        controller?.rootView.list = displayedList!
        timeController?.rootView.list = displayedList!
    }
    @objc func segmentChanged(_ sender: UISegmentedControl) {
            switch sender.selectedSegmentIndex {
            case 0:
                print("quasune")
                scrollView?.setContentOffset(CGPoint(x: 0.0, y: 0.0), animated: true)
            case 1:
                print("pasune")
                scrollView?.setContentOffset(CGPoint(x: view.frame.width, y: 0.0), animated: true)
            default:
                break
            }
        }
    var lapArray:[Int]?
    var timeArray: [Int]?
    var dayEnumerated2 = ["Monday": 1, "Tuesday": 2, "Wednesday": 3, "Thursday": 4, "Friday": 5, "Saturday": 6, "Sunday": 7]
    var dayEnumerated = [1:"Monday",2:"Tuesday", 3:"Wednesday", 4:"Thursday", 5:"Friday", 6:"Saturday",7:"Sunday"]
    var controller:UIHostingController<LapChart>?
    var timeController:UIHostingController<TimeChart>?
    var segmentedController:UISegmentedControl?
    var displayedList:[LapModel]?
    override func viewDidAppear(_ animated: Bool) {
        //print("bitchl")
        dailyLapsSubheading?.text = "\(dailyLaps)"
    }
    func formatTime(seconds: Int) -> String {
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            return String(format: "%02d:%02d", minutes, remainingSeconds)  // Format time as mm:ss
        }
    var scrollView: UIScrollView?
    override func viewDidLoad() {
        /*var list = [
            LapModel(day: "Mon", lapCount: 4),
            LapModel(day: "Tue", lapCount: 4),
            LapModel(day: "Wed", lapCount: 8),
            LapModel(day: "Thu", lapCount: 2),
            LapModel(day: "Fri", lapCount: 4),
            LapModel(day: "Sat", lapCount: 6),
            LapModel(day: "Sun", lapCount: 3)
        ]*/
        /*segmentedController = UISegmentedControl(items: ["Laps", "Times"])

                // Set the frame
                segmentedController?.frame = CGRect(x: 50, y: 80, width: 250, height: 40)
        segmentedController?.isUserInteractionEnabled = true
        
        segmentedController?.center.x = view.center.x
        segmentedController?.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
                // Optionally set other properties
                segmentedController?.selectedSegmentIndex = 0
        view.addSubview(segmentedController!)*/
        scrollView = UIScrollView()
        scrollView?.frame = CGRect(x: 0.0, y: 90.0, width: view.frame.width, height: view.frame.height - 90)
        scrollView?.isUserInteractionEnabled = false
        scrollView?.contentSize.width = view.frame.width * 2
        //scrollView?.contentOffset.x = 300
        view.addSubview(scrollView!)
        var list = [LapModel]()
        var daysInorder = [String]()
        var startDay = defaults.integer(forKey: "startDay")
        lapArray = defaults.array(forKey: "lapArray") as? [Int]
        timeArray = defaults.array(forKey: "timeArray") as? [Int]
        //print("quasmo \(timeArray)")
        for i in startDay...7{
            daysInorder.append(String(dayEnumerated[i]!.prefix(3)))
        }
        for i in 1..<startDay{
            daysInorder.append(String(dayEnumerated[i]!.prefix(3)))
        }
        
        for i in 0..<daysInorder.count{
            list.append(LapModel(day: daysInorder[i], timeInSeconds: timeArray![i], lapCount: lapArray![i]))
        }
        displayedList = list
        controller = UIHostingController(rootView: LapChart(list: displayedList!))
        timeController = UIHostingController(rootView: TimeChart(list: displayedList!))
        guard let chartView = controller?.view else{
            return
        }
        
        scrollView?.addSubview(chartView)
        
        chartView.frame = CGRect(x: 20, y: 0, width: view.frame.width - 20, height: view.frame.height/2.8)
        dailyLaps = defaults.integer(forKey: "dailyLaps")
        weeklyLaps = defaults.integer(forKey: "weeklyLaps")
        totalLaps = defaults.integer(forKey: "totalLaps")
        var remainingSpace = (view.frame.height - chartView.frame.origin.y + chartView.frame.height)
        var availableHeight = remainingSpace
        
        
        dailyLapsHeading = UILabel()
        dailyLapsHeading?.text = "Todays Laps"
                dailyLapsHeading?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        //dailyLapsHeading?.translatesAutoresizingMaskIntoConstraints = false
        dailyLapsHeading?.frame = CGRect(x: 0.0, y: chartView.frame.origin.y + chartView.frame.height + 25, width: view.frame.width, height: 40)
        //dailyLapsHeading?.backgroundColor = .red
        dailyLapsHeading!.center.x = view.center.x
        dailyLapsHeading?.textAlignment = .center

                // Create the Daily Laps subheading label
                dailyLapsSubheading = UILabel()
                dailyLapsSubheading?.text = "\(dailyLaps)" // Example count
                dailyLapsSubheading?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
                //dailyLapsSubheading?.translatesAutoresizingMaskIntoConstraints = false
        dailyLapsSubheading?.frame = CGRect(x: 0.0, y: dailyLapsHeading!.frame.maxY, width: view.frame.width, height: 40)
        dailyLapsSubheading?.center.x = view.center.x
        dailyLapsSubheading?.textAlignment = .center

                // Create the Weekly Laps heading label
                weeklyLapsHeading = UILabel()
                weeklyLapsHeading?.text = "Weekly Laps"
                weeklyLapsHeading?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
                //weeklyLapsHeading?.translatesAutoresizingMaskIntoConstraints = false
        weeklyLapsHeading?.frame = CGRect(x: 0.0, y: dailyLapsSubheading!.frame.maxY, width: view.frame.width, height: 40)
        weeklyLapsHeading!.center.x = view.center.x
        weeklyLapsHeading?.textAlignment = .center

                // Create the Weekly Laps subheading label
                weeklyLapsSubheading = UILabel()
                weeklyLapsSubheading?.text = "\(weeklyLaps)"
                weeklyLapsSubheading?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
                //weeklyLapsSubheading?.translatesAutoresizingMaskIntoConstraints = false
        weeklyLapsSubheading?.frame = CGRect(x: 0.0, y: weeklyLapsHeading!.frame.maxY, width: view.frame.width, height: 40)
        weeklyLapsSubheading!.center.x = view.center.x
        weeklyLapsSubheading?.textAlignment = .center

                // Create the Total Laps heading label
                totalLapsHeading = UILabel()
        totalLapsHeading?.text = "Total Laps"
                totalLapsHeading?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        //totalLapsHeading?.translatesAutoresizingMaskIntoConstraints = false
        totalLapsHeading?.frame = CGRect(x: 0.0, y: weeklyLapsSubheading!.frame.maxY, width: view.frame.width, height: 40)
        totalLapsHeading?.center.x = view.center.x
        totalLapsHeading?.textAlignment = .center

                // Create the Total Laps subheading label
                totalLapsSubheading = UILabel()
        totalLapsSubheading?.text = "\(totalLaps)"
                totalLapsSubheading?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
               // totalLapsSubheading?.translatesAutoresizingMaskIntoConstraints = false
        totalLapsSubheading?.frame = CGRect(x: 0.0, y: totalLapsHeading!.frame.maxY, width: view.frame.width, height: 40)
        totalLapsSubheading!.center.x = view.center.x
        totalLapsSubheading?.textAlignment = .center

                // Add labels to the view
        
        scrollView?.addSubview(dailyLapsHeading!)
        scrollView?.addSubview(dailyLapsSubheading!)
        scrollView?.addSubview(weeklyLapsHeading!)
        scrollView?.addSubview(weeklyLapsSubheading!)
        scrollView?.addSubview(totalLapsHeading!)
        scrollView?.addSubview(totalLapsSubheading!)

                // Calculate the spacing between labels
                let spacingBetweenLabels: CGFloat = 20 // The vertical spacing between the labels

                // Set constraints for the Daily Laps heading and subheading
                /*NSLayoutConstraint.activate([
                    dailyLapsHeading!.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: chartView.frame.origin.y + chartView.frame.height),
                    dailyLapsHeading!.centerXAnchor.constraint(equalTo: view.centerXAnchor),

                    dailyLapsSubheading!.topAnchor.constraint(equalTo: dailyLapsHeading!.bottomAnchor, constant: 8),
                    dailyLapsSubheading!.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                ])

                // Set constraints for the Weekly Laps heading and subheading
                NSLayoutConstraint.activate([
                    weeklyLapsHeading!.topAnchor.constraint(equalTo: dailyLapsSubheading!.bottomAnchor, constant: spacingBetweenLabels),
                    weeklyLapsHeading!.centerXAnchor.constraint(equalTo: view.centerXAnchor),

                    weeklyLapsSubheading!.topAnchor.constraint(equalTo: weeklyLapsHeading!.bottomAnchor, constant: 8),
                    weeklyLapsSubheading!.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                ])

                // Set constraints for the Total Laps heading and subheading
                NSLayoutConstraint.activate([
                    totalLapsHeading!.topAnchor.constraint(equalTo: weeklyLapsSubheading!.bottomAnchor, constant: spacingBetweenLabels),
                    totalLapsHeading!.centerXAnchor.constraint(equalTo: view.centerXAnchor),

                    totalLapsSubheading!.topAnchor.constraint(equalTo: totalLapsHeading!.bottomAnchor, constant: 8),
                    totalLapsSubheading!.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                ])*/
        
        
        
                /* hi
                 
                 */
        scrollView?.showsHorizontalScrollIndicator = false
        scrollView?.isScrollEnabled = false
        
        //var startDay = defaults.integer(forKey: "startDay")
        lapArray = defaults.array(forKey: "lapArray") as? [Int]
        timeArray = defaults.array(forKey: "timeArray") as? [Int]
        var currentDay = dayEnumerated2[Date().dayOfWeek()!]
        if currentDay! >= startDay{
            dailyTimes = timeArray![currentDay! - startDay]
            dailyTimes /= max(1, lapArray![currentDay! - startDay])
        }
        else{
            dailyTimes = timeArray![7 - startDay + currentDay!]
            dailyTimes /= max(1, lapArray![7 - startDay + currentDay!])
        }
        var lapCount = 0
        var timeCount = 0
        for i in 0...6{
            lapCount += lapArray![i]
            timeCount += timeArray![i]
        }
        weeklyTimes = timeCount/max(1, lapCount)
        //print(timeCount)
        //print(lapCount)
        //print(weeklyTimes)
        //chartView.backgroundColor = .red
        guard let chartView2 = timeController?.view else{
            return
        }
        
        scrollView?.addSubview(chartView2)
        
        chartView2.frame = CGRect(x: 20 + view.frame.width, y: 70, width: view.frame.width - 20, height: view.frame.height/2.8)
        //dailyTimes = defaults.integer(forKey: "dailyTimes")
        //weeklyTimes = defaults.integer(forKey: "weeklyTimes")
        //totalLaps = defaults.integer(forKey: "totalLaps")
        var remainingSpace2 = (view.frame.height - chartView2.frame.origin.y + chartView2.frame.height)
        var availableHeight2 = remainingSpace2
        
        
        dailyTimesHeading = UILabel()
        dailyTimesHeading?.text = "Average Lap Today"
                dailyTimesHeading?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        //dailyTimesHeading?.translatesAutoresizingMaskIntoConstraints = false
        dailyTimesHeading?.frame = CGRect(x: 0.0, y: chartView2.frame.maxY + 25, width: view.frame.width, height: 40)
        dailyTimesHeading?.center.x = view.center.x + view.frame.width
dailyTimesHeading?.textAlignment = .center
                // Create the Daily Laps subheading label
                dailyTimesSubheading = UILabel()
                dailyTimesSubheading?.text = "\(formatTime(seconds: dailyTimes))" // Example count
                dailyTimesSubheading?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
                //dailyTimesSubheading?.translatesAutoresizingMaskIntoConstraints = false
                dailyTimesSubheading?.frame = CGRect(x: 0.0, y: dailyTimesHeading!.frame.maxY, width: view.frame.width, height: 40)
                dailyTimesSubheading?.center.x = view.center.x + view.frame.width
        dailyTimesSubheading?.textAlignment = .center
                // Create the Weekly Laps heading label
                weeklyTimesHeading = UILabel()
                weeklyTimesHeading?.text = "Average Weekly Lap"
                weeklyTimesHeading?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
               // weeklyTimesHeading?.translatesAutoresizingMaskIntoConstraints = false
                weeklyTimesHeading?.frame = CGRect(x: 0.0, y: dailyTimesSubheading!.frame.maxY, width: view.frame.width, height: 40)
                weeklyTimesHeading?.center.x = view.center.x + view.frame.width
        weeklyTimesHeading?.textAlignment = .center
                // Create the Weekly Laps subheading label
                weeklyTimesSubheading = UILabel()
                weeklyTimesSubheading?.text = "\(formatTime(seconds: weeklyTimes))"
                weeklyTimesSubheading?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
                //weeklyTimesSubheading?.translatesAutoresizingMaskIntoConstraints = false
        weeklyTimesSubheading?.frame = CGRect(x: 0.0, y: weeklyTimesHeading!.frame.maxY, width: view.frame.width, height: 40)
            weeklyTimesSubheading?.center.x = view.center.x + view.frame.width
        weeklyTimesSubheading?.textAlignment = .center

                // Create the Total Laps heading label
                /*totalLapsHeading = UILabel()
        totalLapsHeading?.text = "Total Laps"
                totalLapsHeading?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        totalLapsHeading?.translatesAutoresizingMaskIntoConstraints = false

                // Create the Total Laps subheading label
                totalLapsSubheading = UILabel()
        totalLapsSubheading?.text = "\(totalLaps)"
                totalLapsSubheading?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
                totalLapsSubheading?.translatesAutoresizingMaskIntoConstraints = false*/

                // Add labels to the view
        scrollView?.addSubview(dailyTimesHeading!)
        scrollView?.addSubview(dailyTimesSubheading!)
        scrollView?.addSubview(weeklyTimesHeading!)
        scrollView?.addSubview(weeklyTimesSubheading!)
                //view.addSubview(totalLapsHeading!)
                //view.addSubview(totalLapsSubheading!)

                // Calculate the spacing between labels
                let spacingBetweenLabels2: CGFloat = 20 // The vertical spacing between the labels
                
        //dailyTimesHeading?.frame = dailyLapsHeading!.frame
                // Set constraints for the Daily Laps heading and subheading
                /*NSLayoutConstraint.activate([
                    dailyTimesHeading!.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: chartView.frame.origin.y + chartView.frame.height),
                    dailyTimesHeading!.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: view.frame.width),

                    dailyTimesSubheading!.topAnchor.constraint(equalTo: dailyTimesHeading!.bottomAnchor, constant: 8),
                    dailyTimesSubheading!.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: view.frame.width),
                ])

                // Set constraints for the Weekly Laps heading and subheading
                NSLayoutConstraint.activate([
                    weeklyTimesHeading!.topAnchor.constraint(equalTo: dailyTimesSubheading!.bottomAnchor, constant: spacingBetweenLabels),
                    weeklyTimesHeading!.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: view.frame.width),

                    weeklyTimesSubheading!.topAnchor.constraint(equalTo: weeklyTimesHeading!.bottomAnchor, constant: 8),
                    weeklyTimesSubheading!.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: view.frame.width),
                ])

                // Set constraints for the Total Laps heading and subheading
                /*NSLayoutConstraint.activate([
                    totalLapsHeading!.topAnchor.constraint(equalTo: weeklyLapsSubheading!.bottomAnchor, constant: spacingBetweenLabels),
                    totalLapsHeading!.centerXAnchor.constraint(equalTo: view.centerXAnchor),

                    totalLapsSubheading!.topAnchor.constraint(equalTo: totalLapsHeading!.bottomAnchor, constant: 8),
                    totalLapsSubheading!.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                ])*/*/
            
        
    }
}
