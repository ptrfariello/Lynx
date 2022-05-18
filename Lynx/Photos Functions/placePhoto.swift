//
//  placePhoto.swift
//  Lynx
//
//  Created by Pietro on 16/05/22.
//

import Foundation
import Photos
import UIKit


class PlaceCell{
    var place: Location!
    var photo: UIImage!
    
    init(place: Location){
        self.place = place
        fetchPhoto()
    }
    
    func fetchPhoto() {
        let imgManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.isNetworkAccessAllowed = true
        let fetchOptions = PHFetchOptions()
        var images: [UIImage] = []
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(withLocalIdentifiers: place.photoIDs, options: fetchOptions)
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
                        self.photo = image
                    }
                })
            }
        }
    }
}
