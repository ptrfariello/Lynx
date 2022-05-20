//
//  scrollPhoto.swift
//  Lynx
//
//  Created by Pietro on 20/05/22.
//

import Foundation
import UIKit
import Photos

class PhotoZoomViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    var id:  String!
    var photoIndex: Int!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        fetchPhoto()
    }
    
    override func viewWillLayoutSubviews() {
      super.viewWillLayoutSubviews()
        updateMinZoomScaleForSize(self.scrollView.bounds.size)
        updateConstraintsForSize(self.scrollView.bounds.size)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateMinZoomScaleForSize(self.scrollView.bounds.size)
        updateConstraintsForSize(self.scrollView.bounds.size)
    }
  
    
    
    
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
                        self.updateMinZoomScaleForSize(self.scrollView.bounds.size)
                        self.updateConstraintsForSize(self.scrollView.bounds.size)
                    }
                })
            }
        }
    }
}


extension PhotoZoomViewController {
    func updateMinZoomScaleForSize(_ size: CGSize) {
        let widthScale = size.width / imageView.intrinsicContentSize.width
        let heightScale = size.height / imageView.intrinsicContentSize.height
        let minScale = min(widthScale, heightScale)
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
    }
    
    func updateConstraintsForSize(_ size: CGSize) {
        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset
        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset
        view.layoutIfNeeded()
    }
}

//MARK:- UIScrollViewDelegate
extension PhotoZoomViewController: UIScrollViewDelegate {
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return imageView
  }
  
  func scrollViewDidZoom(_ scrollView: UIScrollView) {
    updateConstraintsForSize(scrollView.bounds.size)
  }
}
