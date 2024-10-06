//
//  TimerCell.swift
//  Circlr
//
//  Created by Vasisht Muduganti on 9/5/24.
//

import UIKit

class TimerCell: UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var timeNumber: UILabel!
    
    func updateTimerDisplay(time: String) {
        timeLabel.text = time
    }
}
