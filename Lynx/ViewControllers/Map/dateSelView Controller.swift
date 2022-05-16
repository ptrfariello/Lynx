//
//  dateSelView Controller.swift
//  Lynx
//
//  Created by Pietro on 09/05/22.
//

import Foundation
import UIKit

class dateSelController: UIViewController {
    
    
    
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    
    @IBAction func srtDateChanged(_ sender: Any) {
        endDatePicker.minimumDate = startDatePicker.date
    }
    @IBAction func endDateChanged(_ sender: Any) {
        startDatePicker.maximumDate = endDatePicker.date
    }
    
    override func viewDidLoad() {
        startDatePicker.setDate(sharedData.shared.startDate, animated: false)
        endDatePicker.setDate(sharedData.shared.endDate, animated: false)
        endDatePicker.maximumDate = Date.now.addingTimeInterval(3600*24*7)
        startDatePicker.maximumDate = endDatePicker.date
    }
    
}


