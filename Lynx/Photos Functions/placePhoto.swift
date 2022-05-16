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
        let start = sharedData.shared.startDate
        let end = sharedData.shared.endDate
        let imgManager = PHImageManager.default()
        let ids = selectPhotosIDs(location: self.place, start: start, end: end)
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.isNetworkAccessAllowed = true
        let fetchOptions = PHFetchOptions()
        var images: [UIImage] = []
        let size = CGSize(width: 100.0, height: 100.0)
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(withLocalIdentifiers: ids, options: fetchOptions)
        // If the fetch result isn't empty,
        // proceed with the image request
        if fetchResult.count > 0 {
            // Perform the image request
            for index in 0  ..< fetchResult.count  {
                let asset = fetchResult.object(at: index)
                imgManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: requestOptions, resultHandler: { (image, _) in
                    if let image = image {
                        // Add the returned image to your array
                        images += [image]
                    }
                    if images.count == 1 {
                        self.photo = images[0]
                        return
                    }
                })
            }
        }
    }
}
