//
//  ViewController.swift
//  Lynx
//
//  Created by Pietro on 04/05/22.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet private var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Initial Location
        let initialLocation = CLLocation(latitude: 37.695670, longitude: 24.060816)
        mapView.centerToLocation(location: initialLocation)
    }


}

private extension MKMapView {
  func centerToLocation(location: CLLocation, regionRadius: CLLocationDistance = 1000){
    let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
}
