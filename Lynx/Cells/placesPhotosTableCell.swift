//
//  placePhotosCell.swift
//  Lynx
//
//  Created by Pietro on 15/05/22.
//

import UIKit
import Photos




class placesPhotosTableCell: UITableViewCell {
    
    var place: Location!
    
    
    @IBOutlet weak var cellText: UITextView!
    @IBOutlet weak var cellPhoto: UIImageView!
    func create(place: Location){
        self.place = place
        self.cellText.text = place.name
        self.fetchPhoto()
    }
    
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func fetchPhoto() {
        let ids = selectPhotosIDs(ids: place.photoIDs, start: sharedData.shared.startDate, end: sharedData.shared.endDate)
        let imgManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.isNetworkAccessAllowed = true
        let fetchOptions = PHFetchOptions()
        var images: [UIImage] = []
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(withLocalIdentifiers: ids, options: fetchOptions)
        // If the fetch result isn't empty,
        // proceed with the image request
        if fetchResult.count > 0 {
            while images.count < 1{
            // Perform the image request
                let index = Int.random(in: 0..<fetchResult.count)
                let asset = fetchResult.object(at: index)
                imgManager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: requestOptions, resultHandler: { (image, _) in
                    if let image = image {
                        // Add the returned image to your array
                        images += [image]
                        self.cellPhoto.image = image
                    }
                })
            }
        }
    }
    
    
    
}
