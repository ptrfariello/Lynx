//
//  pageController.swift
//  Lynx
//
//  Created by Pietro on 20/05/22.
//

import Foundation
import UIKit

class PhotoSwipeViewController: UIPageViewController {
    var ids: [String]!
    var currentIndex: Int!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // 1
    if let viewController = ZoomedPhotoViewController(currentIndex ?? 0) {
      let viewControllers = [viewController]
      
      // 2
      setViewControllers(viewControllers,
                         direction: .forward,
                         animated: false,
                         completion: nil)
    }
      dataSource = self
  }
    
  
  func ZoomedPhotoViewController(_ index: Int) -> PhotoZoomViewController? {
    guard
      let storyboard = storyboard,
      let page = storyboard
        .instantiateViewController(withIdentifier: "ZoomedPhotoViewController")
        as? PhotoZoomViewController
      else {
        return nil
    }
    page.id = ids[index]
    page.photoIndex = index
    return page
  }
}

extension PhotoSwipeViewController: UIPageViewControllerDataSource {
  func pageViewController(
    _ pageViewController: UIPageViewController,
    viewControllerBefore viewController: UIViewController)
      -> UIViewController? {
    if let viewController = viewController as? PhotoZoomViewController,
      let index = viewController.photoIndex,
      index > 0 {
        return ZoomedPhotoViewController(index - 1)
    }
    
    return nil
  }
  
  func pageViewController(
    _ pageViewController: UIPageViewController,
    viewControllerAfter viewController: UIViewController)
      -> UIViewController? {
    if let viewController = viewController as? PhotoZoomViewController,
      let index = viewController.photoIndex,
      (index + 1) < ids.count {
        return ZoomedPhotoViewController(index + 1)
    }
    
    return nil
  }
}
