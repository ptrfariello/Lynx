//
//  mapView Controller.swift
//  Lynx
//
//  Created by Pietro on 04/05/22.
//

import UIKit
import MapKit

class mapViewController: UIViewController {

    @IBOutlet private var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Initial Location
        let initialLocation = CLLocation(latitude: 37.695670, longitude: 24.060816)
        mapView.centerToLocation(location: initialLocation)
        drawPath()
    }

    func drawPath() {
        mapView?.delegate = self
        Task{
            do{
        var path = await coord_to_display(start: "2022-05-01", end: "2022-05-03")
        let polyline = MKPolyline(coordinates: &path, count: path.count)
        self.mapView?.addOverlay(polyline)
            }
        }
    }
}

private extension MKMapView {
  func centerToLocation(location: CLLocation, regionRadius: CLLocationDistance = 1000){
    let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
}




extension mapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
            
        else {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView") ?? MKAnnotationView()
            annotationView.image = UIImage(named: "place icon")
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView.canShowCallout = true
            return annotationView
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.orange
            renderer.lineWidth = 3
            return renderer
        
        }
        return MKOverlayRenderer()
    }
    
}

