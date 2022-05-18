//
//  largePhoto.swift
//  Lynx
//
//  Created by Pietro on 17/05/22.
//

import UIKit
import Photos

class largePhotoViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var id: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPhoto()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func fetchPhoto() {
        let imgManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.isNetworkAccessAllowed = true
        let fetchOptions = PHFetchOptions()
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [self.id], options: fetchOptions)
        // If the fetch result isn't empty,
        // proceed with the image request
        if fetchResult.count > 0 {
            for index in 0 ..< fetchResult.count{
            // Perform the image request
                let asset = fetchResult.object(at: index)
                imgManager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: requestOptions, resultHandler: { (image, _) in
                    if let image = image {
                        // Add the returned image to your array
                        self.imageView.image = image
                    }
                })
            }
        }
    }

}
