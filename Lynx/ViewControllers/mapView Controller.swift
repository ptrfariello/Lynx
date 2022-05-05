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
                
                let maxLat = Double(path.map(\.latitude).max()!)
                let maxLong = Double(path.map(\.longitude).max()!)
                let minLat = Double(path.map(\.latitude).min()!)
                let minLong = Double(path.map(\.longitude).min()!)
                
                let bottom_left = CLLocation(latitude: minLat, longitude: minLong)
                let top_right = CLLocation(latitude: maxLat, longitude: maxLong)
                
                let zoom = bottom_left.distance(from: top_right)
                let centerY = (maxLat + minLat) / 2
                let centerX = (maxLong + minLong) / 2
                let location = CLLocationCoordinate2D(latitude: centerY, longitude: centerX)
                
                let region =  MKCoordinateRegion(center: location, latitudinalMeters: zoom, longitudinalMeters: zoom)
                self.mapView.setRegion(region, animated: true)
                
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

