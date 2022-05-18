//
//  Place Photos View Controller.swift
//  Lynx
//
//  Created by Pietro on 17/05/22.
//

import UIKit
import Photos

private let reuseIdentifier = "photoCell"

class placePhotoViewController: UICollectionViewController {
    
    var location: Location!
    var photos: [UIImage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPhotos()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! photoCell
    
        cell.image.image = photos[indexPath.row]
    
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if let destination = segue.destination as? largePhotoViewController,
        let indexPath = collectionView.indexPathsForSelectedItems {
          destination.image = photos[indexPath[0].row]
      }
    }
    
    
    func fetchPhotos() {
        let imgManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.isNetworkAccessAllowed = true
        let fetchOptions = PHFetchOptions()
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(withLocalIdentifiers: location.photoIDs, options: fetchOptions)
        // If the fetch result isn't empty,
        // proceed with the image request
        if fetchResult.count > 0 {
            for index in 0 ..< fetchResult.count{
            // Perform the image request
                let asset = fetchResult.object(at: index)
                imgManager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: requestOptions, resultHandler: { (image, _) in
                    if let image = image {
                        // Add the returned image to your array
                        if index > self.photos.count-1 {self.photos.append(image)}else{
                        self.photos[index] = image
                        }
                    }
                })
            }
        }
    }

}
