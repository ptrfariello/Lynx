//
//  photoCell.swift
//  Lynx
//
//  Created by Pietro on 17/05/22.
//

import UIKit
import Photos

class photoCollectionCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
    var id: String!
    
    func create(id: String){
        self.id = id
        fetchPhoto()
    }
    
    func fetchPhoto() {
        let imgManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.isNetworkAccessAllowed = true
        let fetchOptions = PHFetchOptions()
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [self.id], options: fetchOptions)
        let size = CGSize(width: 250, height: 250)
        // If the fetch result isn't empty,
        // proceed with the image request
        if fetchResult.count > 0 {
            for index in 0 ..< fetchResult.count{
            // Perform the image request
                let asset = fetchResult.object(at: index)
                imgManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: requestOptions, resultHandler: { (image, _) in
                    if let image = image {
                        // Add the returned image to your array
                        self.image.image = image
                    }
                })
            }
        }
    }
}
