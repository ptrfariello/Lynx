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
    var photosIDs: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        photosIDs = location.photoIDs
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
        return photosIDs.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! photoCell
    
        cell.create(id: location.photoIDs[indexPath.row])
    
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if let destination = segue.destination as? largePhotoViewController,
        let indexPath = collectionView.indexPathsForSelectedItems {
          destination.id = location.photoIDs[indexPath[0].row]
      }
    }
    
    
   

}
