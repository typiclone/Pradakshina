//
//  ViewController.swift
//  Pradakshina
//
//  Created by Vasisht Muduganti on 9/17/24.
//

import CoreLocation
import CoreMotion
import UIKit
import AVKit
import CoreHaptics
import AudioToolbox

class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    var width = 100
    var height = 100
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    var lapTargets:[Int]?
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return lapTargets?.count ?? 0
    }
    func triggerAlarm() {
        UIApplication.shared.isIdleTimerDisabled = false
        timer?.invalidate()
        timer = nil
        stopSilentAudio()
        resetButton?.backgroundColor = .systemRed
        resetButton?.isUserInteractionEnabled = true
        if alarmSwitch.isOn == true{
            pickerView?.isUserInteractionEnabled = true
            UIView.animate(withDuration: 0.15) {
                self.pickerView?.layer.opacity = 1.0
            }
            
        }
        //lapCounter = 0
        currentCheckpoint = 0
        highestDegreeInCurrentLap = 0
        self.circularProgressView.setProgress(to: CGFloat(0), didFinish: firstCheckPointReached, clockwise: clockwise)
        clockwise = false
        firstTurnPoint = 0
        firstCheckPointReached = false
        lastSpeed = 0
        currentCheckpointSelected = 0
        initialDegree = -1
        lastDegree = 0.0
        origList?.removeAll()
        //updateLapCount()
        updateCheckpointCounter()
        setStartButton.setTitle("Start", for: .normal)
        setStartButton.backgroundColor = UIColor.systemGreen
        
        
        let blurEffect = UIBlurEffect(style: .dark)
                self.blurEffectView?.effect = blurEffect
                
                // Animate the blur effect
        UIView.animate(withDuration: 0.3) { [self] in
                    self.blurEffectView?.layer.opacity = 1.0
                    okayButton?.layer.opacity = 1.0
                    goalLabel?.layer.opacity = 1.0
                }
        view?.bringSubviewToFront(okayButton!)
        view.bringSubviewToFront(goalLabel!)
                // Play haptic feedback and audio in a loop
                let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
                feedbackGenerator.prepare() // Prepare for haptic feedback
                
                // Play haptic feedback and sound
                for i in 0..<10 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + (Double(i) * 1.0)) { // 1 second interval
                        if self.okayButton?.layer.opacity == 1.0{
                            feedbackGenerator.impactOccurred()
                            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                        }
                    }
                }
                
                // Stop any currently playing audio
                audioPlayer?.stop()
                
                // Prepare and play the audio
                guard let soundURL = Bundle.main.url(forResource: "success", withExtension: "mp3") else { return }
                
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                    audioPlayer?.numberOfLoops = 5 // Loop 5 times
                    audioPlayer?.play()
                } catch {
                    //print("Failed to play audio: \(error)")
                }
        
       

                // Create the "Goal Reached" label
        
        
        }
    @objc func okayButtonTapped() {
        audioPlayer?.stop()
        UIView.animate(withDuration: 0.3) { [self] in
            self.blurEffectView?.layer.opacity = 0.0
            okayButton?.layer.opacity = 0.0
            goalLabel?.layer.opacity = 0.0
        }// Action when button is tapped
           // You can perform any action here
       }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return CGFloat(width)
    }
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return CGFloat(height)
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: width, height: height)
        label.font = UIFont.systemFont(ofSize: 30)
        label.textAlignment = .center
        label.text = "\(lapTargets?[row] ?? 0)"
        view.addSubview(label)
        
        view.transform = CGAffineTransform(rotationAngle: 90 * (Double.pi/180))
        
        return view
    }
    
    let locationManager = CLLocationManager()
    var startingLocation: CLLocation?
    let motionManager = CMMotionManager()
    var lapCounter = 0
    var checkpoints = [0,90,180,270]
    var reverseCheckPoints = [0,90,180,270]
    var currentCheckpoint = 0
    var currentCheckpointSelected = 0
    var degrees:Double = 0.0
    var initialDegree = -1
    var firstCheckPointReached = false
    var circularProgressView: CircularProgressView!
    var counterCircularProgressView: CircularProgressView!
    var dayEnumerated = ["Monday": 1, "Tuesday": 2, "Wednesday": 3, "Thursday": 4, "Friday": 5, "Saturday": 6, "Sunday": 7]
    /*let distanceLabel: UILabel = {
        let label = UILabel()
        label.text = "Distance: 0.0 meters"
        label.font = UIFont.systemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()*/
    var startTime: Date?
        var timer: Timer?
        var elapsedTime: TimeInterval = 0

        let timeLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.monospacedDigitSystemFont(ofSize: 100, weight: .semibold)
            label.textAlignment = .center
            label.text = "0"
            return label
        }()
    
    
    var firstTurnPoint = 0
    var clockwise = true
    let lapLabel: UILabel = {
        let label = UILabel()
        label.text = "Laps: 0"
        label.font = UIFont.systemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()
    let checkpointLabel: UILabel = {
        let label = UILabel()
        label.text = "Checkpoint: 0"
        label.font = UIFont.systemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()
    
    let setStartButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        button.backgroundColor = UIColor.systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25  // Makes it pill-shaped
        button.layer.masksToBounds = true
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 4
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)  // Adds padding
        button.frame = CGRect(x: 0, y: 0, width: 250, height: 50) // Adjusts width and height
        return button
    }()
    let fakeStartButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        button.backgroundColor = UIColor.systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25  // Makes it pill-shaped
        button.layer.masksToBounds = true
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 4
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)  // Adds padding
        button.frame = CGRect(x: 0, y: 0, width: 250, height: 50) // Adjusts width and height
        return button
    }()
    
    let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        button.backgroundColor =  #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25  // Makes it pill-shaped
        button.layer.masksToBounds = true
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 4
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)  // Adds padding
        button.frame = CGRect(x: 0, y: 0, width: 250, height: 50) // Adjusts width and height
        return button
    }()
    var lapArray = [0,0,0,0,0,0,0]
    var timeArray = [0,0,0,0,0,0,0]
    func checkIfFirstLoad(){
        
        //////////print("hinterfield")
        
        var dayOfWeek = dayEnumerated[Date().dayOfWeek()!]
        var currentTime = Date().timeIntervalSince1970
        if defaults.integer(forKey: "startDay") == 0{
            defaults.setValue(dayOfWeek, forKey: "startDay")
            var endWeekTime = currentTime + 604800
            defaults.setValue(endWeekTime, forKey: "endWeekTime")
            defaults.setValue([0,0,0,0,0,0,0], forKey: "lapArray")
            defaults.setValue([0,0,0,0,0,0,0], forKey: "timeArray")
            lapArray = [0,0,0,0,0,0,0]
            timeArray = [0,0,0,0,0,0,0]
        }
        else{
            lapArray = defaults.array(forKey: "lapArray") as? [Int] ?? [0,0,0,0,0,0,0]
            timeArray = defaults.array(forKey: "timeArray") as? [Int] ?? [0,0,0,0,0,0,0]
           
        }
        
        var endWeekTime = defaults.integer(forKey: "endWeekTime")
        var lastOpenedTime = defaults.integer(forKey: "lastOpenedTime")
        var lastOpenedDay = defaults.integer(forKey: "lastOpenedDay")
        if lastOpenedTime != 0{
            
            if (dayOfWeek != lastOpenedDay){
                defaults.setValue(0, forKey: "dailyLaps")
            }
            //print(currentTime, endWeekTime)
            if Int(currentTime) > endWeekTime{
                //////////print(currentTime)
                //////////print(endWeekTime)
                //////////print("zingo")
                defaults.setValue(0, forKey: "dailyLaps")
                defaults.setValue(0, forKey: "weeklyLaps")
                defaults.setValue([0,0,0,0,0,0,0], forKey: "lapArray")
                defaults.setValue([0,0,0,0,0,0,0], forKey: "timeArray")
                lapArray = [0,0,0,0,0,0,0]
                timeArray = [0,0,0,0,0,0,0]
                defaults.setValue(currentTime + 604800, forKey: "endWeekTime")
                defaults.setValue(dayOfWeek, forKey: "startDay")
            }
            
        }
        defaults.setValue(currentTime, forKey: "lastOpenedTime")
        defaults.setValue(dayOfWeek, forKey: "lastOpenedDay")
        defaults.setValue(Date().timeIntervalSince1970, forKey: "lastDayOpened")
        
    }
    var stopTimer: Timer?
    func startStopTimer(after interval: TimeInterval) {
        stopTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [self] _ in
            stopSilentAudio()
        }
    }
    func stopSilentAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
        stopTimer?.invalidate()
        stopTimer = nil
    }
    func setupAudioSession() {
        do {
            // Set the audio session category to playback to support background audio
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            //////////print("Failed to set up audio session: \(error)")
        }
    }
    //var timerTable: UITableView?

       

       @objc func updateTimer() {
           guard let startTime = startTime else { return }
           elapsedTime = Date().timeIntervalSince(startTime)
           timeLabel.text = formatTime(elapsedTime)
          /* let indexPath = IndexPath(row: 0, section: 0)
           if let cell = timerTable?.cellForRow(at: indexPath) as? TimerCell {
               cell.timeLabel.text = timeLabel.text
                   }*/
       }
    func formatTime(minutes: Int, seconds: Int, milliseconds: Int) -> String {
        // Format the string with leading zeros
        let formattedTime = String(format: "%02d:%02d:%03d", minutes, seconds, milliseconds)
        return formattedTime
    }
       func formatTime(_ timeInterval: TimeInterval) -> String {
           let minutes = Int(timeInterval) / 60
           let seconds = Int(timeInterval) % 60
           let milliseconds = Int((timeInterval * 1000).truncatingRemainder(dividingBy: 1000))
           return String(format: "%02d:%02d:%03d", minutes, seconds, milliseconds)
       }
   /* @objc func proximityChanged(notification: NSNotification) {
        if UIDevice.current.proximityState == true {
            // Phone is near a surface (likely in pocket)
            //////print("Phone is in pocket")
        } else {
            // Phone is away from surface (likely taken out of pocket)
            //////print("Phone is out of pocket")
        }
    }*/
    var blurEffectView:UIVisualEffectView?
    func showTutorial(){
        self.tabBarController?.tabBar.isHidden = true
        if let tabBar = self.tabBarController?.tabBar {
            tabBar.isUserInteractionEnabled = false
        }
        self.tabBarController?.tabBar.backgroundColor = .clear
        nextButton.isUserInteractionEnabled = true
        view.addSubview(fakeStartButton)
        fakeStartButton.layer.opacity = 1.0
        view.bringSubviewToFront(fakeStartButton)
        fakeStartButton.frame.size = CGSize(width: 100, height: 50)
        fakeStartButton.center.x = view.center.x
        fakeStartButton.tag = 69420
        
        view.addSubview(nextButton)
        nextButton.backgroundColor = .gray
        nextButton.isUserInteractionEnabled = false
        nextButton.layer.opacity = 1.0
        view.bringSubviewToFront(nextButton)
        nextButton.frame.size = CGSize(width: view.frame.width/2 - 50, height: 50)
        nextButton.center.x = view.center.x
        
        var thirdImage = UIImageView(frame: CGRect(x: 0, y: 120, width: 50, height: 50))
        thirdImage.contentMode = .scaleAspectFit
        thirdImage.image = UIImage(systemName: "hand.point.up.left")
        thirdImage.tintColor = .black
        
        thirdImage.center.x = view.center.x
        thirdImage.layer.opacity = 1.0
        thirdImage.tag = 69420
        view.addSubview(thirdImage)
        
        fakeStartButton.center.y = thirdImage.frame.origin.y
        nextButton.frame.origin.y = view.frame.height - 100
        
        var secondLabel = UILabel(frame: CGRect(x: 0.0, y: fakeStartButton.frame.maxY + 50, width: view.frame.width, height: 200.0))
        secondLabel.text = "Tap the                  button"
        secondLabel.textAlignment = .center
        secondLabel.frame.origin.y = fakeStartButton.frame.maxY
        secondLabel.center.x = view.center.x
        secondLabel.numberOfLines = 0
        secondLabel.textColor = .black
        secondLabel.tag = 69420
        secondLabel.lineBreakMode = .byWordWrapping
        secondLabel.layer.opacity = 1.0
        secondLabel.font = UIFont(name: "Helvetica Neue", size: 28)
        fakeStartButton.center.x = secondLabel.center.x
        fakeStartButton.center.y = secondLabel.center.y
        fakeStartButton.isUserInteractionEnabled = false
        //firstLabel.font = UIFont.systemFont(ofSize: 30)
        view.addSubview(secondLabel)
        thirdImage.center.y = fakeStartButton.center.y + 35
        
        var firstImage = UIImageView(frame: CGRect(x: 0, y: secondLabel.frame.maxY - 20, width: view.frame.width/2, height: 200))
        firstImage.contentMode = .scaleAspectFit
        firstImage.image =  #imageLiteral(resourceName: "DALL_E_2024-09-12_00.45.31_-_A_modern__minimalist_icon_showing_a_hand_placing_a_smartphone_into_a_pant_pocket._The_hand_is_sleek_with_clean_lines__and_the_phone_has_a_simple__rect-removebg")
        firstImage.center.x = view.center.x/2
        firstImage.tag = 69420
        firstImage.layer.opacity = 0.0
        view.addSubview(firstImage)
        
        var secondImage = UIImageView(frame: CGRect(x: 0, y: secondLabel.frame.maxY - 20, width: view.frame.width/2, height: 200))
        secondImage.contentMode = .scaleAspectFit
        secondImage.image =  #imageLiteral(resourceName: "DALL_E_2024-09-12_01.11.18_-_A_minimalist__modern_icon_of_a_hand_holding_a_smartphone_sideways__as_if_the_person_is_grabbing_it._The_focus_is_on_the_hand_and_the_phone__with_clean-removebg")
        secondImage.tintColor = .white
        secondImage.tag = 69420
        secondImage.center.x = view.center.x + view.center.x/2
        secondImage.layer.opacity = 0.0
        view.addSubview(secondImage)
        
        var firstLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width - 150, height: 200.0))
        firstLabel.text = "Place your phone in your pocket, or keep by side while moving."
        firstLabel.textAlignment = .center
        firstLabel.frame.origin.y = secondImage.frame.maxY
        firstLabel.center.x = view.center.x
        firstLabel.numberOfLines = 0
        firstLabel.tag = 69420
        firstLabel.textColor = .black
        firstLabel.lineBreakMode = .byWordWrapping
        firstLabel.layer.opacity = 0.0
        firstLabel.font = UIFont(name: "Helvetica Neue", size: 28)
        //firstLabel.font = UIFont.systemFont(ofSize: 30)
        view.addSubview(firstLabel)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            UIView.animate(withDuration: 1.0, delay: 2.0) {
                firstLabel.layer.opacity = 1.0
                secondImage.layer.opacity = 1.0
                firstImage.layer.opacity = 1.0
            } completion: { [self] done in
                if(done){
                    nextButton.backgroundColor =  #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
                    nextButton.isUserInteractionEnabled = true
                }
            }

        })
        
        var personImage = UIImageView(frame: CGRect(x: 300.0, y: 300.0, width: 300, height: 300))
        personImage.tag = 696969
        personImage.center.x = view.center.x
        personImage.center.y = view.center.y - 100
        personImage.layer.opacity = 0.0
        
        var secondLabel2 = UILabel(frame: CGRect(x: 0.0, y: personImage.frame.maxY + 50, width: view.frame.width - 70, height: 200.0))
        secondLabel2.text = "Keep the app open and start moving!"
        secondLabel2.textAlignment = .center
        secondLabel2.frame.origin.y = personImage.frame.maxY - 50
        secondLabel2.center.x = view.center.x
        secondLabel2.numberOfLines = 0
        secondLabel2.textColor = .black
        secondLabel2.tag = 696969
        secondLabel2.lineBreakMode = .byWordWrapping
        secondLabel2.layer.opacity = 1.0
        secondLabel2.font = UIFont(name: "Helvetica Neue", size: 28)
        secondLabel2.layer.opacity = 0.0
        
        
        
        
        personImage.contentMode = .scaleAspectFit
        personImage.tag = 696969
        personImage.image =  #imageLiteral(resourceName: "walker")
        view.addSubview(personImage)
        view.addSubview(secondLabel2)
       
        
        
        
    }
    func isiPhoneSE3rdGen() -> Bool {
        let screenSize = UIScreen.main.bounds.size
        let height = max(screenSize.width, screenSize.height) // Ensure we always compare against height

        // iPhone SE (3rd Gen) has a screen size of 667 points in height
        return height == 667.0
    }
    
    @objc func nextButtonAction(sender: UIButton){
       
        //print("hidonkz")
                    
        UIView.animate(withDuration: 0.4) {
            
            for i in self.view.subviews{
                if i.tag == 696969 && i.layer.opacity == 1.0{
                    self.blurEffectView?.layer.opacity = 0.0
                    //print("bakachin")
                    i.layer.opacity = 0.0
                    self.nextButton.layer.opacity = 0.0
                    self.tabBarController?.tabBar.isUserInteractionEnabled = true
                    
                    self.tabBarController?.tabBar.isHidden = false
                }
                else if i.tag == 696969 && i.layer.opacity == 0.0{
                    
                    i.layer.opacity = 1.0
                }
            }
            
        }
                    
          
        UIView.animate(withDuration: 0.4) {
            for i in self.view.subviews{
                if i.tag == 69420{
                    i.layer.opacity = 0.0
                }
            }
        }
        /*var backgroundLayer = CAShapeLayer()
        var backgroundCircleColor: UIColor = #colorLiteral(red: 0.9986872077, green: 0.3591775596, blue: 0.006945624482, alpha: 1)
        backgroundLayer.path = UIBezierPath(arcCenter: CGPoint(x: view.frame.width/2, y: 300.0), radius: view.frame.width/2 - 50.0, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true).cgPath
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.strokeColor = backgroundCircleColor.cgColor
        backgroundLayer.lineWidth = 15.0
        backgroundLayer.lineCap = .round
        view.layer.addSublayer(backgroundLayer)*/
        
        
        
        
    }
    @objc func resetButtonTapped() {
            showResetConfirmationAlert()
        }

        // Function to display the confirmation alert
        func showResetConfirmationAlert() {
            let alertController = UIAlertController(title: "Reset Lap Count",
                                                    message: "Are you sure you want to reset the lap count?",
                                                    preferredStyle: .alert)

            // "Yes" action
            let yesAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
                self.resetLapCount()  // Call the reset function
            }

            // "No" action
            let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)

            // Add actions to the alert controller
            alertController.addAction(yesAction)
            alertController.addAction(noAction)

            // Present the alert
            self.present(alertController, animated: true, completion: nil)
        }

        // Function that gets called when the user confirms reset
        func resetLapCount() {
            lapCounter = 0
            checkpoints = [0,90,180,270]
            reverseCheckPoints = [0,90,180,270]
            currentCheckpoint = 0
            currentCheckpointSelected = 0
            degrees = 0.0
            initialDegree = -1
            firstCheckPointReached = false
            lapLabel.text = "0"
            lapLabel.text = "Laps: \(lapCounter)"
            timeLabel.text = "\(lapCounter)"
            //print("Lap count has been reset!")  // Add your reset logic here
        }
    var goalLabel:UILabel?
    var okayButton: UIButton?
    private var hapticEngine: CHHapticEngine?
    var resetButton:UIButton?
    override func viewDidLoad() {
        super.viewDidLoad()
        lapTargets = [Int]()
        for i in 3...120{
            lapTargets?.append(i)
        }
        lapLabel.layer.opacity = 0.0
        
        resetButton = UIButton(type: .system)
                resetButton?.setTitle("Reset", for: .normal)
                resetButton?.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
                resetButton?.setTitleColor(.white, for: .normal)
                resetButton?.backgroundColor = UIColor.systemRed
                
                resetButton?.frame = CGRect(x: 30, y: 60, width: 110, height: 50)
        resetButton?.layer.cornerRadius = (resetButton?.frame.height)!/2// Adjusting for button size
                resetButton?.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)

                // Add shadow for a modern effect
                resetButton?.layer.shadowColor = UIColor.black.cgColor
                resetButton?.layer.shadowOpacity = 0.2
                resetButton?.layer.shadowOffset = CGSize(width: 2, height: 2)
                resetButton?.layer.shadowRadius = 4

                // Add the button to the view
        self.view.addSubview(resetButton!)
        //prepareHaptics()
          //      playVibrationPattern()
       /* let pickerView = UIPickerView()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        var rotationAngle = -90 * (Double.pi/180)
        pickerView.transform = CGAffineTransform(rotationAngle: rotationAngle)
        
               
               
               
               // Set constraints to center the picker view in the screen
        pickerView.frame = CGRect(x: 0, y: setStartButton.frame.maxY + 50, width: view.frame.width, height: 100)
        pickerView.center.x = view.center.x
        view.addSubview(pickerView)*/
        //UIDevice.current.isProximityMonitoringEnabled = true

        //NotificationCenter.default.addObserver(self, selector: #selector(proximityChanged), name: UIDevice.proximityStateDidChangeNotification, object: nil)
        
        goalLabel = UILabel()
                goalLabel?.text = "Goal Reached"
        goalLabel?.font = UIFont.systemFont(ofSize: 50) // Larger font size
                goalLabel?.textColor = .white // Set the text color to white
                goalLabel?.textAlignment = .center
        goalLabel?.layer.opacity = 0.0
                goalLabel?.frame = CGRect(x: 0, y: 200, width: view.frame.width, height: 140) // Adjust height for larger text
        goalLabel?.center.y = view.center.y - 100
                view.addSubview(goalLabel!)

                // Create the "Okay" button
                okayButton = UIButton()
                okayButton?.setTitle("Stop", for: .normal)
                okayButton?.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .medium) // Larger font size for button
                okayButton?.setTitleColor(.white, for: .normal)
                okayButton?.backgroundColor = .orange
                okayButton?.layer.cornerRadius = 20 // Pill shape
                okayButton?.clipsToBounds = true
        okayButton?.layer.opacity = 0.0
                // Set the size and position for the okay button
                let buttonWidth: CGFloat = 200 // Set to 50% of the screen width
                let buttonHeight: CGFloat = 70 // Increased height for better touch area
        okayButton?.frame = CGRect(x: (view.frame.width - buttonWidth) / 2, y: (goalLabel?.frame.maxY)! + 40, width: buttonWidth, height: buttonHeight)

                // Add target for button action
        okayButton?.layer.cornerRadius = (okayButton?.frame.height)!/2
        okayButton!.addTarget(self, action: #selector(okayButtonTapped), for: .touchUpInside)
                
                // Add the button to the view
        view.addSubview(okayButton!)
        
        
        let blurEffect = UIBlurEffect(style: .extraLight)
                
                // Create a UIVisualEffectView using the blur effect
                blurEffectView = UIVisualEffectView(effect: blurEffect)
                
                // Set the frame or use constraints to position it properly
        blurEffectView?.frame = view.frame // Cover the entire screen
        
                // Optionally, if you want the blur to only cover part of the view, adjust the frame accordingly
                // For example, covering only half of the screen:
                // blurEffectView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height / 2)
                
                // Add the blurEffectView to your view
       
        timeRecords = [String]()
        lapNumberArray = [Int]()
        //////////print(defaults.array(forKey: "lapArray"))
        //defaults.set(false, forKey: "firstLoad")
        var agreementAccepted = defaults.bool(forKey: "firstLoad")
        //////////print(agreementAccepted)
       
        checkIfFirstLoad()
        smooth = [Double]()
        setupAudioSession()
        
        origList = [Int]()
        setupLocationManager()
        setupMotionManager()
        last2Checkpoints = []
        setStartButton.addTarget(self, action: #selector(setStartingPoint(sender:)), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButtonAction(sender:)), for: .touchUpInside)
        
        circularProgressView = CircularProgressView(frame: CGRect(x: 0, y: 0, width: view.frame.width - 100, height: view.frame.width - 100))
        circularProgressView.center = view.center
        circularProgressView.frame.origin.y = 150
        view.addSubview(circularProgressView)
        
        
        
        /*counterCircularProgressView = CircularProgressView(frame: CGRect(x: 0, y: 0, width: 200, height: 200), clockwise: false)
        counterCircularProgressView.center = view.center
        counterCircularProgressView.frame.origin.x = 0
       
        //counterCircularProgressView.mirrorHorizontally()
        view.addSubview(counterCircularProgressView)*/
            
               // Start updating the circle
        updateCircleProgress()
        
        
        view.addSubview(timeLabel)
        
        //timeLabel.backgroundColor = .red
        //timeLabel.frame.size.height = 100
        timeLabel.frame = CGRect(x: 0, y: 0, width: circularProgressView.frame.width - 50, height: circularProgressView.frame.height - 100)
        timeLabel.center = circularProgressView.center
        timeLabel.adjustsFontSizeToFitWidth = true
        
        setupUI()
        var tabBarHeight = self.tabBarController?.tabBar.frame.size.height
        var heightForTable = view.frame.height - (setStartButton.frame.origin.y + setStartButton.frame.height + 30)
        heightForTable -= tabBarHeight! + 40
        /*timerTable = UITableView(frame: CGRect(x: 0, y: setStartButton.frame.origin.y + setStartButton.frame.height + 30, width: view.frame.width - 40, height: heightForTable))
        timerTable?.delegate = self
        timerTable?.dataSource = self
        timerTable?.showsVerticalScrollIndicator = false
        //timerTable?.backgroundColor = .red
        timerTable?.center.x = view.center.x
        
        timerTable?.register(UINib(nibName: "TimerCell", bundle: nil), forCellReuseIdentifier: "TimerCell")
               
               // Register default UITableViewCell for frozen time cells
               
        view.addSubview(timerTable!)*/
        /*timeLabel.frame.size.width = circularProgressView.frame.size.width - 50
                timeLabel.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    timeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    timeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: (200 + (view.frame.width - 100)/2) - timeLabel.frame.size.height/2)
                ])*/

                // Setup Start and Stop Buttons
                /*let startButton = UIButton(type: .system)
                startButton.setTitle("Start", for: .normal)
                startButton.addTarget(self, action: #selector(startTimer), for: .touchUpInside)

                let stopButton = UIButton(type: .system)
                stopButton.setTitle("Stop", for: .normal)
                stopButton.addTarget(self, action: #selector(stopTimer2), for: .touchUpInside)

                let stackView = UIStackView(arrangedSubviews: [startButton, stopButton])
                stackView.axis = .horizontal
                stackView.spacing = 20

                view.addSubview(stackView)
                stackView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    stackView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 20)
                ])*/
        
        view.addSubview(blurEffectView!)
        countdownLabel = UILabel()
               countdownLabel.textAlignment = .center
               countdownLabel.textColor = .white
               countdownLabel.font = UIFont.systemFont(ofSize: 100)
               countdownLabel.alpha = 0.0  // Start invisible
               countdownLabel.translatesAutoresizingMaskIntoConstraints = false
        countdownLabel.frame.size.height = 100
               view.addSubview(countdownLabel)
               
               // Center the label in the view
               NSLayoutConstraint.activate([
                   countdownLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                   countdownLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
               ])
        //print("agreer", agreementAccepted)
        if agreementAccepted == false{
            defaults.setValue(true, forKey: "firstLoad")
            UIView.animate(withDuration: 0.3) {
                let blurEffect = UIBlurEffect(style: .extraLight)
                self.blurEffectView?.effect = blurEffect
                self.blurEffectView?.layer.opacity = 1.0
            }
            
            /*DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                let alertController = UIAlertController(title: "Attention: ", message: "To ensure smooth operation and uninterrupted performance, silent audio is played in the background. This helps keep the app running efficiently while processing important tasks.", preferredStyle: .alert)
                        //////////print("open up dawg")
                let agreeAction = UIAlertAction(title: "Allow", style: .default) { [self] _ in
                            // Handle the agree action
                            defaults.setValue(1, forKey: "agreementAccepted")
                            //////////print("Agree button pressed")
                        }
                        
                        alertController.addAction(agreeAction)
                        
                        self.present(alertController, animated: true, completion: nil)
            })*/
            showTutorial()
            
            
        }
        else{
            blurEffectView?.layer.opacity = 0.0
        }
    }
   
        
        @objc func updateCountdown() {
            if secondsRemaining > 0 {
                UIView.animate(withDuration: 0.2) {
                    let blurEffect = UIBlurEffect(style: .dark)
                    self.blurEffectView?.effect = blurEffect
                    self.blurEffectView?.layer.opacity = 1.0
                }
                countdownLabel.text = "\(secondsRemaining)"
                animateCountdownLabel()
                secondsRemaining -= 1
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.blurEffectView?.layer.opacity = 0.0
                }
                countdownTimer?.invalidate()
                countdownLabel.text = ""
                performFunctionAfterCountdown()
            }
        }
        
        func animateCountdownLabel() {
            countdownLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            countdownLabel.alpha = 0.0
            let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.impactOccurred()
            UIView.animate(withDuration: 0.5, animations: { [self] in
                self.countdownLabel.alpha = 1.0
                self.countdownLabel.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }) { _ in
                UIView.animate(withDuration: 0.5, animations: {
                    self.countdownLabel.alpha = 0.0
                    self.countdownLabel.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
                })
            }
        }
        
        func performFunctionAfterCountdown() {
            // Function to call after countdown ends
            startTime = Date()
            setStartButton.isUserInteractionEnabled = true
            ////print("papez")
            //timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            //if let currentLocation = locationManager.location {
                //startingLocation = currentLocation
                //lapCounter = 0 // Reset lap counter
                //distanceLabel.text = "Starting point set"
                lapLabel.text = "Laps: \(lapCounter)"
            timeLabel.text = "\(lapCounter)"
                firstCheckPointReached = false
                ////print("lapez", degrees)
                initialDegree = Int(degrees)
                indicatorAngle = 0
                lastSpeed = 0
                firstTurnPoint = 0
                tracking = true
                currentCheckpoint = 0
                currentCheckpointSelected = 0
                highestDegreeInCurrentLap = 0
                var baseCount = initialDegree
                
                for i in 0..<checkpoints.count{
                    baseCount = baseCount + 90
                    if baseCount > 360{
                        baseCount = baseCount - 360
                    }
                    checkpoints[i] = baseCount
                }
                updateCheckPointCounterLabel()
                updateLapCount()
                //////////print("lordy \(checkpoints)")
            //}
            //////////print("Countdown complete!")
        }
    var timeRecords:[String]?
    var lastSpeed = 0
    var highestDegreeInCurrentLap = 0
    var lastDegree = 0.0
    var origList:[Int]?
    var tracking = true
    var countdownLabel: UILabel!
        var countdownTimer: Timer?
        var secondsRemaining = 5
    var testing = false
    var hapticDisabled = true
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    var lapNumberArray:[Int]?
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimerCell", for: indexPath) as! TimerCell
        cell.isUserInteractionEnabled = false
        
        cell.timeNumber.text = "Lap \(lapNumberArray?[indexPath.row] ?? 1)"
        cell.timeLabel.text = "\(timeRecords?[indexPath.row] ?? "00:00:000")"
        
        return cell
        }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timeRecords!.count// +1 for the running timer cell
        }
    func checkInBoundsLaterTimer(highest: Int){
        
        Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [self] timer in
            if tracking == true{
                if inBounds(int1: highest, int2: highest, degrees: Int(indicatorAngle)){
                    tracking = true
                    ////////////print("true track \(highest) \(indicatorAngle) ||||| \(highestDegreeInCurrentLap)")
                }
                else{
                    ////////////print("false track \(highest) \(indicatorAngle) ||||| \(highestDegreeInCurrentLap)")
                    
                    tracking = false
                    trackableDone = false
                    Timer.scheduledTimer(withTimeInterval: 0.15, repeats: false) { [self] timers in
                        trackableDone = true
                    }
                }
            }
            
            
        }
    }
    var realClockwise = true
    func updateCircleProgress() {
            // Simulate real-time updates
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true){ [self] timer in
            ////print(lastSpeed, firstTurnPoint, highestDegreeInCurrentLap, indicatorAngle)
            if abs(lastDegree - indicatorAngle) > 270{
                            if indicatorAngle > 0 && indicatorAngle < 100{
                                realClockwise = true
                                
                            }
                            else if indicatorAngle < 360 && indicatorAngle > 270{
                                realClockwise = false
                            }
                        }
            yaws += indicatorAngle - lastDegree
            if Int(indicatorAngle) - Int(lastDegree) < -100{
                origList?.append(Int(360 - lastDegree + indicatorAngle))
            }
            else if Int(indicatorAngle) - Int(lastDegree) > 100{
                origList?.append(Int(360 - indicatorAngle + lastDegree))
            }
            else{
                origList?.append(Int(indicatorAngle) - Int(lastDegree))
            }
            yawCounter += 1
            ////////////print(origList)
            if origList?.count == 3{
                lastSpeed = ((origList?.reduce(0, +))!)/3
                if firstCheckPointReached{
                    if firstTurnPoint == 0{
                        firstTurnPoint = lastSpeed
                    }
                    ////////////print("lastSpeed", lastSpeed, "firstTurn", firstTurnPoint, "indic", indicatorAngle, "highest", highestDegreeInCurrentLap)
                    //////////print(lastSpeed, firstTurnPoint)
                    if clockwise == true{
                        if lastSpeed + 1 >= firstTurnPoint{
                           // //////////print("gomenasai")
                            checkInBoundsLaterTimer(highest: highestDegreeInCurrentLap)
                        }
                    }
                    else{
                        if lastSpeed <= firstTurnPoint{
                            ////////////print("gomenasai")
                            checkInBoundsLaterTimer(highest: highestDegreeInCurrentLap)
                        }
                    }
                }
               // //////////print(lastSpeed)
                origList?.remove(at: 0)
                yawCounter = 0
            }
            lastDegree = indicatorAngle
        }
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [self] timer in
            //print("kowais")
            if initialDegree != -1{
                if firstCheckPointReached == true{
                    ////////////print(highestDegreeInCurrentLap)
                    ///
                    //print("chowais")
                    self.circularProgressView.setProgress(to: CGFloat(highestDegreeInCurrentLap), didFinish: firstCheckPointReached, clockwise: clockwise)
                }
                else{
                    ////print("bowais")
                    self.circularProgressView.setProgress(to: CGFloat(indicatorAngle), didFinish: firstCheckPointReached, clockwise: clockwise)
                }
            }
            
                //self.circularProgressView.setProgress(to: Float(CGFloat(self.indicatorAngle/360.0)))
                //self.counterCircularProgressView.setProgress(to: Float(CGFloat(self.indicatorAngle/360.0)))
                
                
            }
        }
    var targetLap = -1
    var pickerView: UIPickerView?
    func setupUI() {
        //view.addSubview(distanceLabel)
        view.addSubview(lapLabel)
        view.addSubview(checkpointLabel)
        view.addSubview(setStartButton)
        
        //distanceLabel.translatesAutoresizingMaskIntoConstraints = false
        //lapLabel.translatesAutoresizingMaskIntoConstraints = false
        //checkpointLabel.translatesAutoresizingMaskIntoConstraints = false
        //setStartButton.translatesAutoresizingMaskIntoConstraints = false
        
        /*NSLayoutConstraint.activate([
            //distanceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            //distanceLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            lapLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lapLabel.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 120),
            
            checkpointLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            checkpointLabel.topAnchor.constraint(equalTo: lapLabel.bottomAnchor, constant: 20),
            
            setStartButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            setStartButton.topAnchor.constraint(equalTo: checkpointLabel.bottomAnchor, constant: 20)
        ])*/
        
        lapLabel.frame.origin.y = circularProgressView.frame.origin.y + circularProgressView.frame.height + 50
        lapLabel.frame.size = CGSize(width: view.frame.width/2 - 50, height: 50)
        lapLabel.center.x = view.frame.width/4
        if isiPhoneSE3rdGen(){
            setStartButton.frame.origin.y = circularProgressView.frame.origin.y + circularProgressView.frame.height + 30
        }
        else{
            setStartButton.frame.origin.y = circularProgressView.frame.origin.y + circularProgressView.frame.height + 50
        }
        setStartButton.frame.size = CGSize(width: view.frame.width/2 - 50, height: 50)
        setStartButton.center.x = view.frame.width - view.frame.width/4
        pickerView = UIPickerView()
        pickerView?.layer.opacity = 0.0
        pickerView?.delegate = self
        pickerView?.dataSource = self
        var rotationAngle = -90 * (Double.pi/180)
        pickerView?.transform = CGAffineTransform(rotationAngle: rotationAngle)
        
               
               
               
               // Set constraints to center the picker view in the screen
        if isiPhoneSE3rdGen(){
            pickerView?.frame = CGRect(x: 0, y: setStartButton.frame.maxY + 10, width: view.frame.width, height: 100)
        }
        else{
            pickerView?.frame = CGRect(x: 0, y: setStartButton.frame.maxY + 50, width: view.frame.width, height: 100)
        }
        pickerView?.center.x = view.center.x
        view.addSubview(pickerView!)
        pickerView?.selectRow(5, inComponent: 0, animated: false)
        targetLap = lapTargets?[(lapTargets?.count ?? 0)/2] ?? 0
        
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: pickerView!.frame.maxY, width: 200, height: 50)
        
        containerView.frame = lapLabel.frame
        containerView.frame.origin.x = containerView.frame.origin.x + 30
        self.view.addSubview(containerView)

                // Create the Alarm label with a bigger, more aesthetic font
                let alarmLabel = UILabel()
                alarmLabel.text = "Alarm"
                alarmLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)  // Larger and bold for aesthetic appeal
                alarmLabel.textColor = .systemGray  // Softer gray color for a modern look
                alarmLabel.sizeToFit()
        if isiPhoneSE3rdGen(){
            alarmLabel.frame = CGRect(x: 0, y: (containerView.frame.height - alarmLabel.frame.height) / 2 - 20, width: alarmLabel.frame.width, height: alarmLabel.frame.height)
        }
        else{
            alarmLabel.frame = CGRect(x: 0, y: (containerView.frame.height - alarmLabel.frame.height) / 2, width: alarmLabel.frame.width, height: alarmLabel.frame.height)
        }
                containerView.addSubview(alarmLabel)

                // Create the UISwitch
                alarmSwitch = UISwitch()
                alarmSwitch.isOn = false // Default is off
        if isiPhoneSE3rdGen(){
            alarmSwitch.frame = CGRect(x: alarmLabel.frame.maxX + 10, y: (containerView.frame.height - alarmSwitch.frame.height) / 2 - 20, width: alarmSwitch.frame.width, height: alarmSwitch.frame.height)
        }
        else{
            alarmSwitch.frame = CGRect(x: alarmLabel.frame.maxX + 10, y: (containerView.frame.height - alarmSwitch.frame.height) / 2, width: alarmSwitch.frame.width, height: alarmSwitch.frame.height)
        }
                alarmSwitch.addTarget(self, action: #selector(switchToggled(_:)), for: .valueChanged)
        containerView.addSubview(alarmSwitch)
    }
    var alarmSwitch = UISwitch()
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(targetLap != -1){
            targetLap = (lapTargets?[row])!
        }
        //print("cucumber", targetLap)
    }
    @objc func switchToggled(_ sender: UISwitch) {
            if sender.isOn {
                
                targetLap = (lapTargets?[pickerView?.selectedRow(inComponent: 0) ?? -1])!
                UIView.animate(withDuration: 0.2) {
                    if self.setStartButton.title(for: .normal) == "Stop" {
                        self.pickerView?.layer.opacity = 0.5
                        self.pickerView?.isUserInteractionEnabled = false
                    }
                    else{
                        self.pickerView?.layer.opacity = 1.0
                        self.pickerView?.isUserInteractionEnabled = true
                    }
                }
                
                //print("Alarm switched ON")
            } else {
                targetLap = -1
                UIView.animate(withDuration: 0.2) {
                    self.pickerView?.layer.opacity = 0.0
                    self.pickerView?.isUserInteractionEnabled = true
                }
                //print("Alarm switched OFF")
            }
        }
    var angleY: Double = 0.0
    var lastTimestamp: TimeInterval?
    var previousYawDegrees: Double = 0.0
    var yawRate: Double = 0.0
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    var yawCounter = 0
    var yaws = 0.0
    var lastString = "00"
    func setupMotionManager() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.01
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!) { [weak self] (motion, error) in
                guard let self = self, let motion = motion, error == nil else {
                    return
                }
                /*var lastSixCharacters = timeLabel.text?.suffix(6)
                    
                    // Extract the 5th and 6th digits from the end
                if audioPlayer?.isPlaying == true{
                    let fifthCharacter = lastSixCharacters?.first
                    lastSixCharacters = lastSixCharacters?.dropFirst()// 5th from the end
                    let sixthCharacter = lastSixCharacters?.first
                    var newString = "\(fifthCharacter!)\(sixthCharacter!)"
                    //print(newString)
                    if newString != lastString{
                        lastString = newString
                        let lastLaunchTime = UserDefaults.standard.double(forKey: "lastLaunchTime")
                        
                        // Calculate the time interval since the last launch
                        let timeSinceLastLaunch = Date().timeIntervalSince1970 - lastLaunchTime
                        //print("kaunch", timeSinceLastLaunch)
                        if timeSinceLastLaunch >= 10 {
                            //print("hola como esta")
                            // Perform the action (e.g., stop playing audio)
                            stopSilentAudio()
                            
                        }
                    }
                }*/
                
                let yawDegrees = self.calculateYawDegrees(from: motion.attitude.quaternion)
                
                
                self.yawRate = (yawDegrees - self.previousYawDegrees) / motionManager.deviceMotionUpdateInterval
                ////////////print(abs(yawRate))
                //print("yaw", yawDegrees, "check", currentCheckpoint, "indic", indicatorAngle, "checks", checkpoints, "highest", highestDegreeInCurrentLap, "direction", clockwise, "init", initialDegree, "track", tracking, "track2", trackableDone)
                self.previousYawDegrees = yawDegrees
                
                DispatchQueue.main.async { [self] in
                    self.degrees = yawDegrees
                    
                    if self.initialDegree != -1{
                        self.checkForCheckpointCrossing(degrees: yawDegrees)
                    }
                   // //////////print("Accurate Yaw (rotation around y-axis, independent of tilt): \(self.degrees) degrees")
                }
            }
        }
        
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.01
            motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { [weak self] (data, error) in
                guard let self = self, let accelerometerData = data else { return }
                self.processAccelerometerData(accelerometerData)
            }
        }
    }
    var last2Checkpoints:[Int]?
    func returnCheckpointArea() -> Int{
       // //////////print("gangshy", checkpoints)
        
            var closestIndex = 0
        var minDistance = Int.max
            
            for (index, checkpoint) in checkpoints.enumerated() {
                // Calculate direct distance
                let directDistance = abs(Int(degrees) - checkpoint)
                
                // Calculate the wrapped distance over 360 degrees
                let wrappedDistance = min(directDistance, 360 - directDistance)
                
                if wrappedDistance < Int(minDistance) {
                    minDistance = wrappedDistance
                    closestIndex = index
                }
            }
        if closestIndex == 3{
            if last2Checkpoints?.count ?? 0 >= 1{
                if 0 != last2Checkpoints![last2Checkpoints!.count - 1]{
                    if last2Checkpoints?.count == 2{
                        last2Checkpoints?.remove(at: 0)
                    }
                    last2Checkpoints?.append(0)
                }
            }
            else{
                last2Checkpoints?.append(0)
            }
            return 0
        }
        else if closestIndex == 1 || closestIndex == 0 || closestIndex == 2{
            if last2Checkpoints?.count ?? 0 >= 1{
                if closestIndex + 1 != last2Checkpoints![last2Checkpoints!.count - 1]{
                    if last2Checkpoints?.count == 2{
                        last2Checkpoints?.remove(at: 0)
                    }
                    last2Checkpoints?.append(closestIndex + 1)
                }
            }
            else{
                last2Checkpoints?.append(closestIndex + 1)
            }
            return closestIndex + 1
        }
        return 0
        
        /*for i in 0...2 {
            //if clockwise == false{
                if checkpoints[i + 1] < checkpoints[i]{
                    if (Int(degrees) <= checkpoints[i + 1] && degrees >= 0) || Int(degrees) >= checkpoints[i] && degrees <= 360{
                        return i + 1
                    }
                }
                if Int(degrees) >= checkpoints[i] && Int(degrees) <= checkpoints[i + 1]{
                    return i + 1
                }
            //}
            /*else{
                if checkpoints[i + 1] > checkpoints[i]{
                    if (Int(degrees) <= checkpoints[i] && degrees >= 0) || Int(degrees) <= checkpoints[i + 1]{
                        return i + 1
                    }
                }
                if Int(degrees) <= checkpoints[i] && Int(degrees) >= checkpoints[i + 1]{
                    return i + 1
                }
            }*/
        }
        return 0*/
        
    }
    var indicatorAngle = 0.0
    // Separate function to calculate yaw degrees from the quaternion
    func calculateYawDegrees(from quaternion: CMQuaternion) -> Double {
        let yawRadians = atan2(2.0 * (quaternion.x * quaternion.y + quaternion.w * quaternion.z),
                               quaternion.w * quaternion.w + quaternion.x * quaternion.x - quaternion.y * quaternion.y - quaternion.z * quaternion.z)
        
        var degrees = yawRadians * 180 / .pi
        degrees = fmod(degrees, 360)
        ////////////print(degrees)
        if degrees < 0 {
            degrees += 360
        }
        var diff = self.degrees - degrees
        if self.degrees != 0{
            indicatorAngle += diff
            if indicatorAngle < 0{
                indicatorAngle = indicatorAngle + 360
            }
            else if indicatorAngle > 360{
                indicatorAngle = indicatorAngle - 360
            }
        }
        /*if indicatorAngle > 270{
            self.circularProgressView.layer.opacity = 0.0
            self.counterCircularProgressView.layer.opacity = 1.0
        }
        else{
            self.circularProgressView.layer.opacity = 1.0
            self.counterCircularProgressView.layer.opacity = 0.0
        }*/
       // //////////print(indicatorAngle)
        
        return degrees
    }
    
    // Separate function to check for checkpoint crossing and update lap counter
    func generateLightHapticFeedback() {
        if hapticDisabled == true{
            let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
            feedbackGenerator.prepare()
            feedbackGenerator.impactOccurred()
        }
        
    }
    func convertStringToTimeComponents(timeString: String) -> (minutes: Int, seconds: Int, milliseconds: Int)? {
        // Split the string using ":" and "."
        let timeComponents = timeString.components(separatedBy: ":")
        
        guard timeComponents.count == 3 else {
            //////////print("Invalid time format")
            return nil
        }

        if let minutes = Int(timeComponents[0]),
           let seconds = Int(timeComponents[1]),
           let milliseconds = Int(timeComponents[2]) {
            return (minutes, seconds, milliseconds)
        }

        //////////print("Conversion to Int failed")
        return nil
    }
    var timeComponents = (minutes: 0, seconds: 0, milliseconds: 0)
    func resetCircleData(){
        //self.circularProgressView.resetProgress(animated: true, duration: 0.5, clockwise: clockwise)
        //print("cheapishlyer")
        var currentTimeComponent = timeComponents
        /*timeComponents = convertStringToTimeComponents(timeString: timeLabel.text ?? "00:00:000")!
            var minutes = timeComponents.minutes
            var seconds = timeComponents.seconds
            var milliseconds = timeComponents.milliseconds
            var timeString = formatTime(minutes: minutes, seconds: seconds, milliseconds: milliseconds)
            
            //////////print("Minutes: \(timeComponents.minutes)")
            //////////print("Seconds: \(timeComponents.seconds)")
            //////////print("Milliseconds: \(timeComponents.milliseconds)")
            if timeRecords?.count ?? 0 > 0{
                let difference = timeDifference(time1: timeString, time2: formatTime(minutes: currentTimeComponent.minutes, seconds: currentTimeComponent.seconds, milliseconds: currentTimeComponent.milliseconds))
                timeString = difference
            }
        timeRecords?.insert(timeString, at: 0)*/
        lapNumberArray?.insert(lapCounter, at: 0)
            //////////print("times", timeRecords)
            //timerTable?.insertRows(at: [IndexPath(row: 0, section: 0)], with: .bottom)
        
        
        updateUserDefaults()
        if(Int(timeLabel.text!)! + 1 == targetLap && targetLap != -1){
            triggerAlarm()
        }
        
        if clockwise == true{
            highestDegreeInCurrentLap = 3
        }
        else{
            highestDegreeInCurrentLap = 360
        }
        tracking = true
        lastSpeed = 0
        indicatorAngle = 0
    }
    func timeToMilliseconds(_ time: String) -> Int {
        let components = time.split(separator: ":").map { Int($0) ?? 0 }
        let hours = components[0]
        let minutes = components[1]
        let milliseconds = components[2]
        
        return (hours * 60 * 60 * 1000) + (minutes * 60 * 1000) + milliseconds
    }

    // Convert total milliseconds back to "HH:MM:SSS" format, ensuring milliseconds are 3 digits max
    func millisecondsToTime(_ milliseconds: Int) -> String {
        let hours = milliseconds / (60 * 60 * 1000)
        let remainingMilliseconds = milliseconds % (60 * 60 * 1000)
        
        let minutes = remainingMilliseconds / (60 * 1000)
        let finalMilliseconds = remainingMilliseconds % (60 * 1000)
        
        // Truncate milliseconds to 3 digits if longer
        let truncatedMilliseconds = finalMilliseconds / 1 % 1000
        
        // Format with exactly two digits for hours and minutes, and three digits for milliseconds
        return String(format: "%02d:%02d:%03d", hours, minutes, truncatedMilliseconds)
    }

    // Calculate the time difference between two time strings
    func timeDifference(time1: String, time2: String) -> String {
        let time1Milliseconds = timeToMilliseconds(time1)
        let time2Milliseconds = timeToMilliseconds(time2)
        
        let difference = abs(time1Milliseconds - time2Milliseconds)
        
        return millisecondsToTime(difference)
    }

    func checkForDirection(){
        if firstCheckPointReached == false{
            var lowerBound = checkpoints[0] - 10
            var upperBound = checkpoints[0] + 10
            
            var otherlowerBound = (checkpoints[checkpoints.count - 2] ?? 0) - 10
            var otherupperBound = (checkpoints[checkpoints.count - 2] ?? 0) + 10
            
            if lowerBound < 0 {
                lowerBound = 360 + lowerBound
            }
            if upperBound > 360 {
                upperBound = upperBound - 360
            }
            
            if otherlowerBound < 0 {
                otherlowerBound = 360 + otherlowerBound
            }
            if otherupperBound > 360 {
                otherupperBound = otherupperBound - 360
            }
            
            if lowerBound < upperBound{
                if Int(degrees) >= lowerBound && Int(degrees) <= upperBound {
                    if currentCheckpoint == 3 {
                        lapCounter += 1
                        lapsSinceStart += 1
                        resetCircleData()
                        currentCheckpoint = 0
                    }
                    else{
                        currentCheckpoint += 1
                    }
                    clockwise = false
                    realClockwise = false
                    firstCheckPointReached = true
                    highestDegreeInCurrentLap = Int(indicatorAngle)
                    generateLightHapticFeedback()
                }
            }
            else if lowerBound > upperBound && firstCheckPointReached == false{
                if (degrees >= 0 && Int(degrees) <= upperBound) || (Int(degrees) >= lowerBound && degrees <= 360){
                    if currentCheckpoint == 3 {
                        lapCounter += 1
                        lapsSinceStart += 1
                        resetCircleData()
                        currentCheckpoint = 0
                    }
                    else{
                        currentCheckpoint += 1
                    }
                    clockwise = false
                    realClockwise = false
                    firstCheckPointReached = true
                    highestDegreeInCurrentLap = Int(indicatorAngle)
                    generateLightHapticFeedback()
                }
            }
            
            if otherlowerBound < otherupperBound && firstCheckPointReached == false{
                if Int(degrees) >= otherlowerBound && Int(degrees) <= otherupperBound {
                    if currentCheckpoint == 3 {
                        lapCounter += 1
                        lapsSinceStart += 1
                        resetCircleData()
                        currentCheckpoint = 0
                    }
                    else{
                        currentCheckpoint += 1
                    }
                    reverseCheckPoint()
                    clockwise = true
                    realClockwise = true
                    firstCheckPointReached = true
                    highestDegreeInCurrentLap = Int(indicatorAngle)
                    generateLightHapticFeedback()
                }
            }
            else if otherlowerBound > otherupperBound && firstCheckPointReached == false{
                if (degrees >= 0 && Int(degrees) <= otherupperBound) || (Int(degrees) >= otherlowerBound && degrees <= 360){
                    if currentCheckpoint == 3 {
                        lapCounter += 1
                        lapsSinceStart += 1
                        resetCircleData()
                        currentCheckpoint = 0
                    }
                    else{
                        currentCheckpoint += 1
                    }
                    clockwise = true
                    realClockwise = true
                    reverseCheckPoint()
                    firstCheckPointReached = true
                    highestDegreeInCurrentLap = Int(indicatorAngle)
                    generateLightHapticFeedback()
                }
            }
            
            
        }
    }
    var trackableDone = true
    func reverseCheckPoint(){
        var temp1 = checkpoints[0]
        checkpoints[0] = checkpoints[2]
        checkpoints[2] = temp1
    }
    var lapsSinceStart = 0
    func checkForCheckpointCrossing(degrees: Double) {
        var newCheckpoint = self.returnCheckpointArea()
        ////////////print(currentCheckpoint, newCheckpoint)
        ////////////print("hil \(highestDegreeInCurrentLap)")
        //////////print(last2Checkpoints, currentCheckpoint, highestDegreeInCurrentLap)
        //////print(indicatorAngle)
        ////////print(currentCheckpoint, checkpoints, degrees)
        if firstCheckPointReached == false{
            checkForDirection()
            ////////////print("konichiwa ", checkpoints)
        }
        else{
            /*if inBounds(int1: highestDegreeInCurrentLap, int2: highestDegreeInCurrentLap, degrees: Int(indicatorAngle)){
             tracking = true
             }*/
            ////////////print("sumaaa \(inBounds(int1: highestDegreeInCurrentLap - 10, int2: highestDegreeInCurrentLap + 10, degrees: Int(indicatorAngle)))")
            if lapsSinceStart == 0 && realClockwise != clockwise{
                //////print(realClockwise, clockwise)
                ////////print("opposite", indicatorAngle, highestDegreeInCurrentLap)
                ////////////print(indicatorAngle, highestDegreeInCurrentLap, last2Checkpoints)
                if clockwise == true{
                    //print("lumbaya")
                    let actualAngle = highestDegreeInCurrentLap
                    if abs(Int(360 - indicatorAngle) - highestDegreeInCurrentLap) < 30 && actualAngle < 270 && actualAngle > 70{
                        //////////print("clocked", currentCheckpoint)
                        //////print("swapped!", indicatorAngle, highestDegreeInCurrentLap)
                        clockwise = realClockwise
                        highestDegreeInCurrentLap = Int(360 - highestDegreeInCurrentLap)
                        reverseCheckPoint()
                        
                        //self.circularProgressView.setProgress(to: CGFloat( highestDegreeInCurrentLap), didFinish: firstCheckPointReached, clockwise: false)
                    }
                }
                else{
                    let actualAngle = 360 - highestDegreeInCurrentLap
                    if abs(Int(360 - indicatorAngle) - highestDegreeInCurrentLap) < 30 && actualAngle < 270 && actualAngle > 70{
                        //////////print("anticlock \(highestDegreeInCurrentLap)")
                        clockwise = realClockwise
                        highestDegreeInCurrentLap = Int(360 - highestDegreeInCurrentLap)
                        reverseCheckPoint()
                        
                        //clockwise = !clockwise
                        ////////////print("anticlocked")
                        //self.circularProgressView.setProgress(to: CGFloat(highestDegreeInCurrentLap), didFinish: firstCheckPointReached, clockwise: clockwise)
                    }
                }
            }
            else{
                if clockwise == true && abs(Int(indicatorAngle) - highestDegreeInCurrentLap) <= 30{
                    //print("kumbaya")
                    if tracking == true{
                        highestDegreeInCurrentLap = max(highestDegreeInCurrentLap, Int(indicatorAngle))
                        if highestDegreeInCurrentLap >= 359{
                            //////////print("peter griff")
                            highestDegreeInCurrentLap = 0
                        }
                    }
                    if tracking == false && inBounds(int1: highestDegreeInCurrentLap, int2: highestDegreeInCurrentLap, degrees: Int(indicatorAngle)) && trackableDone{
                        //print("gumbachi")
                        tracking = true
                        highestDegreeInCurrentLap = max(highestDegreeInCurrentLap, Int(indicatorAngle))
                        if highestDegreeInCurrentLap >= 359{
                            //////////print("peter griff")
                            highestDegreeInCurrentLap = 0
                        }
                    }
                    /*else if tracking == true{
                     highestDegreeInCurrentLap = max(highestDegreeInCurrentLap, Int(indicatorAngle))
                     }*/
                }
                else if abs(Int(indicatorAngle) - highestDegreeInCurrentLap) <= 30{
                    if tracking == true{
                        highestDegreeInCurrentLap = min(highestDegreeInCurrentLap, Int(indicatorAngle))
                        //print("trublez \(highestDegreeInCurrentLap) \(indicatorAngle)")
                        if highestDegreeInCurrentLap <= 1{
                            
                            highestDegreeInCurrentLap = 360
                        }
                    }
                    if tracking == false && inBounds(int1: highestDegreeInCurrentLap, int2: highestDegreeInCurrentLap, degrees: Int(indicatorAngle)) && trackableDone{
                        //print("bumblez \(highestDegreeInCurrentLap) \(indicatorAngle)")
                        highestDegreeInCurrentLap = min(highestDegreeInCurrentLap, Int(indicatorAngle))
                        if highestDegreeInCurrentLap <= 1{
                            highestDegreeInCurrentLap = 360
                        }
                        tracking = true
                    }
                }
                if tracking == true{
                    var lowerBound = checkpoints[currentCheckpoint] - 10
                    var upperBound = checkpoints[currentCheckpoint] + 10
                    
                    if lowerBound <= 0 {
                        lowerBound = 360 + lowerBound
                    }
                    if upperBound >= 360 {
                        upperBound = upperBound - 360
                    }
                    
                    if lowerBound < upperBound{
                        
                        if Int(degrees) >= lowerBound && Int(degrees) <= upperBound {
                            updateCheckpointCounter()
                        }
                    }
                    else if lowerBound > upperBound{
                       
                        if (degrees >= 0 && Int(degrees) <= upperBound) || (Int(degrees) >= lowerBound && degrees <= 360){
                            //////////print("doobeydoobey2")
                            updateCheckpointCounter()
                        }
                    }
                    updateCheckPointCounterLabel()
                    updateLapCount()
                }
            }
        }
        
    }
    func inBounds(int1: Int, int2: Int, degrees: Int) -> Bool {
        var lowerBound = int1 - 20
        var upperBound = int2 + 20
        
        // Adjust bounds to handle circular wrapping
        if lowerBound < 0 {
            lowerBound += 360
        }
        if upperBound > 360 {
            upperBound -= 360
        }
        
        // Check if the range does not wrap around
        if lowerBound <= upperBound {
            return degrees >= lowerBound && degrees <= upperBound
        } else {
            // Check if the range wraps around the 0/360 boundary
            return degrees >= lowerBound || degrees <= upperBound
        }
    }
    func updateCheckpointCounter(){
        var newCheckpoint = 0
        //////////print("zoomeyzoomeyzoo", currentCheckpoint,last2Checkpoints)
        //print("cunindrum")
        if realClockwise == clockwise || (currentCheckpoint == 3 && last2Checkpoints == [1,0]) {
            ////////////print(currentCheckpoint, newCheckpoint)
            if currentCheckpoint == 3 {
                lapCounter += 1
                lapsSinceStart += 1
                //updateUserDefaults()
                resetCircleData()
                currentCheckpoint = 0
            }
            else{
                currentCheckpoint += 1
            }
            generateLightHapticFeedback()
        }
        else{
            return
           
        }
        
    }
    let defaults = UserDefaults.standard
    func timeToSeconds(time: String) -> Double? {
        // Split the time string by colon ":"
        let components = time.split(separator: ":")
        
        // Ensure there are exactly 3 components (minutes, seconds, milliseconds)
        guard components.count == 3,
              let minutes = Double(components[0]),
              let seconds = Double(components[1]),
              let milliseconds = Double(components[2]) else {
            return nil
        }
        
        // Convert to total seconds
        let totalSeconds = (minutes * 60) + seconds + (milliseconds / 1000)
        return totalSeconds
    }
    func updateUserDefaults(){
       
    /*var sday = 5
        for i in sday...7{
            //////////print(i)
        }
        for i in 1..<sday{
            //////////print(i)
        }*/
        
        var totalies = defaults.integer(forKey: "totalLaps")
        defaults.setValue(totalies + 1, forKey: "totalLaps")
        var weeklies = defaults.integer(forKey: "weeklyLaps")
        defaults.setValue(weeklies + 1, forKey: "weeklyLaps")
        var dailies = defaults.integer(forKey: "dailyLaps")
        defaults.setValue(dailies + 1, forKey: "dailyLaps")
        
        var timeInSeconds = Int(timeToSeconds(time: timeLabel.text ?? "0") ?? 0)
        
        var weeklyTimes = defaults.integer(forKey: "weeklyTimes")
        defaults.setValue(weeklies + timeInSeconds, forKey: "weeklyTimes")
        var dailyTimes = defaults.integer(forKey: "dailyTimes")
        defaults.setValue(dailies + timeInSeconds, forKey: "dailyTimes")
        
        var currentDay = dayEnumerated[Date().dayOfWeek()!]
        var startDay = defaults.integer(forKey: "startDay")
        //////////print(startDay, currentDay)
        ////print(Int(timeToSeconds(time: timeLabel.text ?? "0") ?? 0))
        if currentDay! >= startDay{
            lapArray[currentDay! - startDay] += 1
            timeArray[currentDay! - startDay] += timeInSeconds
        }
        else{
            lapArray[7 - startDay + currentDay!] += 1
            timeArray[7 - startDay + currentDay!] += timeInSeconds
        }
        ////print("waluigi \(timeArray)")
        defaults.setValue(lapArray, forKey: "lapArray")
        defaults.setValue(timeArray, forKey: "timeArray")
        //////////print("cosmic", lapArray)
        
        if let tabBarController = self.tabBarController {
                    // Access the view controllers
                    if let secondViewController = tabBarController.viewControllers?.first(where: { $0 is Analytics }) as? Analytics {
                        // Do something with secondViewController
                        secondViewController.updateValues()
                    }
                }
    }
    func processAccelerometerData(_ data: CMAccelerometerData) {
        // Handle accelerometer data
        calculateVelocity(acceleration: data.acceleration)
        /*if isWalking(acceleration: data.acceleration) {
                    //////////print("Device is moving like walking")
                    // Execute your code here
                } else {
                    //////////print("Device is not moving like walking")
                }*/
    }
    var velocityX: Double = 0.0
    var velocityY: Double = 0.0
    func calculateVelocity(acceleration: CMAcceleration) {
        // Convert the update interval to seconds
        
    }
    func isWalking(acceleration: CMAcceleration) -> Bool {
        
        let horizontalThreshold: Double = 0.02 // Adjust this threshold to detect horizontal movement
        let verticalThreshold: Double = 1.0 // Higher threshold for vertical to ignore minor up/down motion
        
        // Focus on horizontal movement (x and y) while ignoring significant up/down motion (z)
        let isMovingHorizontally = (abs(acceleration.x) > horizontalThreshold) || (abs(acceleration.y) > horizontalThreshold)
        //let isNotMovingVertically = abs(acceleration.z) < verticalThreshold
        
        return isMovingHorizontally
    }
    func updateCheckPointCounterLabel(){
        checkpointLabel.text = "Checkpoint: \(currentCheckpoint)"
    }
    func updateLapCount(){
        lapLabel.text = "Laps: \(lapCounter)"
        timeLabel.text = "\(lapCounter)"
    }
    
    var accel = 0.0
    var motion = 0.0
    /*func processAccelerometerData(_ data: CMAccelerometerData) {
            let acceleration = data.acceleration
                
                // Assuming gravity is approximately 9.8 m/s^2
        ////////////print(acceleration.z)
            // Example logic to detect specific movement patterns or thresholds
            // You can use acceleration data to detect specific patterns or thresholds
            // for lap detection or movement tracking
        }*/
    var audioPlayer: AVAudioPlayer?

    func startSilentAudio() {
        guard let soundURL = Bundle.main.url(forResource: "silence", withExtension: "wav") else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            audioPlayer?.play()
            //////////print("played!!")
        } catch {
            //////////print("Failed to play audio: \(error)")
        }
    }
    
    @objc func setStartingPoint(sender: UIButton) {
        if sender.title(for: .normal) == "Start" {
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "lastLaunchTime")
            timeLabel.text = "\(lapCounter)"
            realClockwise = true
            clockwise = true
            lapsSinceStart = 0
            timeComponents = (minutes: 0, seconds: 0, milliseconds: 0)
            pickerView?.isUserInteractionEnabled = false
            if alarmSwitch.isOn == true{
                UIView.animate(withDuration: 0.15) {
                    self.pickerView?.layer.opacity = 0.5
                }
            }
            //timeRecords?.removeAll()
            //lapNumberArray?.removeAll()
            //timerTable?.reloadData()
            resetButton?.backgroundColor = .lightGray
            resetButton?.isUserInteractionEnabled = false
                startSilentAudio()
                last2Checkpoints = []
            UIView.animate(withDuration: 0.3) {
                sender.setTitle("Stop", for: .normal)
                sender.backgroundColor = UIColor.systemRed
                UIApplication.shared.isIdleTimerDisabled = true
            }
                
                
            if testing == false{
                setStartButton.isUserInteractionEnabled = false
                secondsRemaining = 5
                countdownLabel.alpha = 0.0
                countdownLabel.textColor = .white
                let blurEffect = UIBlurEffect(style: .dark)
                self.blurEffectView?.effect = blurEffect
                UIView.animate(withDuration: 0.3) {
                    self.blurEffectView?.layer.opacity = 1.0
                }
                
                updateCountdown()
                countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
            }
            else{
                performFunctionAfterCountdown()
            }
            } else {
                UIApplication.shared.isIdleTimerDisabled = false
                timer?.invalidate()
                timer = nil
                stopSilentAudio()
                resetButton?.backgroundColor = .systemRed
                resetButton?.isUserInteractionEnabled = true
                if alarmSwitch.isOn == true{
                    pickerView?.isUserInteractionEnabled = true
                    UIView.animate(withDuration: 0.15) {
                        self.pickerView?.layer.opacity = 1.0
                    }
                    
                }
                //lapCounter = 0
                currentCheckpoint = 0
                highestDegreeInCurrentLap = 0
                self.circularProgressView.setProgress(to: CGFloat(0), didFinish: firstCheckPointReached, clockwise: clockwise)
                clockwise = false
                firstTurnPoint = 0
                firstCheckPointReached = false
                lastSpeed = 0
                currentCheckpointSelected = 0
                initialDegree = -1
                lastDegree = 0.0
                origList?.removeAll()
                //updateLapCount()
                updateCheckpointCounter()
                sender.setTitle("Start", for: .normal)
                sender.backgroundColor = UIColor.systemGreen
            }
            
        
    }
    var smooth:[Double]?
    var averagedValue = 100.0
    var lastLapTimestamp: Date?
    private let lapCooldown: TimeInterval = 0.1
    
    
    // CLLocationManagerDelegate method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
       // //print("qualimono")
        if let startLocation = startingLocation {
            let distance = currentLocation.distance(from: startLocation)
            //distanceLabel.text = String(format: "Distance: %.2f meters", distance)
        }
        var speed: CLLocationSpeed = CLLocationSpeed()
        speed = locationManager.location?.speed ?? 0
        ////print(speed)
        if speed > 0.16{
            timesWalking += 1
        }
        //print(timesWalking)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //////////print("Failed to get user location: \(error.localizedDescription)")
    }
    var timesWalking = 0
}
extension Date {
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).capitalized
        // or use capitalized(with: locale) if you want
    }
}

