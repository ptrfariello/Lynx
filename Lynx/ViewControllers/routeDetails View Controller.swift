//
//  routesView Controller.swift
//  Lynx
//
//  Created by Pietro on 13/05/22.
//

import Foundation
import UIKit
import MapKit
import SwiftUI

class routeDetailViewController: UIViewController, MKMapViewDelegate {
    
    var points: [Point] = []
    var route: Route!
    
    @IBOutlet weak var routeMapView: MKMapView!
    @IBOutlet weak var startText: UITextView!
    @IBOutlet weak var endText: UITextView!
    @IBOutlet weak var maxSpeedLabel: UILabel!
    @IBOutlet weak var avgSpeedLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        routeMapView?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        drawRoute(route: route!)
        startEndText()
        speedText()
    }
    
    func startEndText(){
        var text = "\(print_date(date: route.start, hour: true))\n\n\(route.startPoint.locationName)"
        startText.text = text
        text = "\(print_date(date: route.end, hour: true))\n\n\(route.endPoint.locationName)"
        endText.text = text
    }
    
    func speedText(){
        let maxSpeed = myRound(value: route.maxSpeed?.sog ?? 0, decimalPlaces: 1)
        var text = ""
        if maxSpeed != 0{
         text = "Max Speed: \(myRound(value: route.maxSpeed?.sog ?? 0, decimalPlaces: 1)) kts"
        }
        maxSpeedLabel.text = text
        
        text = "Average Speed: \(myRound(value: route.avgSpeed, decimalPlaces: 1)) kts"
        avgSpeedLabel.text = text
    }
    
    func mapClear(){
        let overlays = routeMapView.overlays
        routeMapView.removeOverlays(overlays)
        let annotations = routeMapView.annotations
        routeMapView.removeAnnotations(annotations)
    }
    
    func drawRoute(route: Route) {
        mapClear()
        route.startPoint.color = startColor
        route.endPoint.color = endColor
        let points = select_points(points: points, from: route.start, to: route.end)
        let path = points.map{ $0.getCoord()}
        let polyline = MKPolyline(coordinates: path, count: path.count)
        
        routeMapView.setVisibleMapRect(polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 50.0, left: 50.0, bottom: 50.0, right: 50.0), animated: false)
       
        self.routeMapView?.addOverlay(polyline)
        
        routeMapView.addAnnotations([route.startPoint, route.endPoint])
        
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.orange
            renderer.lineWidth = 2
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    func mapView(_ MapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let _ = annotation as? MKUserLocation {return nil}
        let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        var color = UIColor.gray
        if let point = annotation as? Point {
            color = point.color
        }
        view.markerTintColor = color
        return view
    }
    
}
