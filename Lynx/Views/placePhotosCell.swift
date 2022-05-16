//
//  placePhotosCell.swift
//  Lynx
//
//  Created by Pietro on 15/05/22.
//

import UIKit
import Photos




class placePhotosCell: UITableViewCell {
    
    var place: Location!
    
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var cellPhoto: UIImageView!
    func create(place: PlaceCell){
        self.place = place.place
        self.cellLabel.text = place.place.locationName
        self.cellPhoto.image = place.photo
    }
    
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    
}
