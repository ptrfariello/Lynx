//
//  Photo Scroll ViewController.swift
//  Lynx
//
//  Created by Pietro on 19/05/22.
//

import UIKit
import Photos

class PhotoScrollViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    var images: [UIImage] = []
    var ids: [String]!
    var startID: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPhotos()
        let frame = CGRect(x: (self.view.frame.size.width * CGFloat(startID)), y: 0, width: self.view.frame.width, height: scrollView.frame.height)
        for i in 0..<images.count {
            let imageView = UIImageView()
            let x = self.view.frame.size.width * CGFloat(i)
            imageView.frame = CGRect(x: x, y: 0, width: self.view.frame.width, height: scrollView.frame.height)
            imageView.contentMode = .scaleAspectFit
            imageView.image = images[i]
            scrollView.contentSize.width = scrollView.frame.size.width * CGFloat(i + 1)
            scrollView.addSubview(imageView)
        }
        scrollView.contentSize.height = 1.0
        scrollView.scrollRectToVisible(frame, animated: false)
    }
    

    func fetchPhotos() {
        let ids = selectPhotosIDs(ids: self.ids, start: sharedData.shared.startDate, end: sharedData.shared.endDate)
        let imgManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.isNetworkAccessAllowed = true
        let fetchOptions = PHFetchOptions()
        let fetchResult: PHFetchResult = PHAsset.fetchAssets(withLocalIdentifiers: ids, options: fetchOptions)
        // If the fetch result isn't empty,
        // proceed with the image request
        if fetchResult.count > 0 {
            for index in 0..<fetchResult.count{
            // Perform the image request
                let asset = fetchResult.object(at: index)
                imgManager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: requestOptions, resultHandler: { (image, _) in
                    if let image = image {
                        // Add the returned image to your array
                        self.images += [image]
                    }
                })
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
