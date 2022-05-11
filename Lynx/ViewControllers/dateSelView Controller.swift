//
//  dateSelView Controller.swift
//  Lynx
//
//  Created by Pietro on 09/05/22.
//

import Foundation
import UIKit

class dateSelController: UIViewController {
    
    var start: Date = Date.now
    var end: Date = Date.now
    
    
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    
    
    @IBAction func srtDateChanged(_ sender: Any) {
        endDatePicker.minimumDate = startDatePicker.date
    }
    @IBAction func endDateChanged(_ sender: Any) {
        startDatePicker.maximumDate = endDatePicker.date
    }
    
    override func viewDidLoad() {
        startDatePicker.setDate(start, animated: false)
        endDatePicker.setDate(end, animated: false)
        endDatePicker.maximumDate = Date.now
        startDatePicker.maximumDate = endDatePicker.date
    }
}


