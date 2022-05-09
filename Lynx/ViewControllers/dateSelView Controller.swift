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
        endDatePicker.maximumDate = endDatePicker.date
    }
}


