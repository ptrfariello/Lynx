//
//  routesView Controller.swift
//  Lynx
//
//  Created by Pietro on 13/05/22.
//

import Foundation
import UIKit
import MapKit

class routeDetailViewController: UIViewController, MKMapViewDelegate {
    var points: [Point] = []
    var route: Route?
    
    @IBOutlet weak var routeMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        routeMapView?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        drawRoute(route: route!)
    }
    
    
    func mapClear(){
        let overlays = routeMapView.overlays
        routeMapView.removeOverlays(overlays)
        let annotations = routeMapView.annotations
        routeMapView.removeAnnotations(annotations)
    }
    
    func drawRoute(route: Route) {
        mapClear()
        route.startMarker.color = UIColor.green
        route.startMarker.color = UIColor.blue
        let points = select_points(points: points, from: route.start, to: route.end)
        let path = points.map{ $0.getCoord()}
        let polyline = MKPolyline(coordinates: path, count: path.count)
        
        routeMapView.setVisibleMapRect(polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 50.0, left: 50.0, bottom: 50.0, right: 50.0), animated: false)
       
        self.routeMapView?.addOverlay(polyline)
        
        routeMapView.addAnnotations([route.startMarker, route.endMarker])
        
    }
    
    func getBearingBetweenTwoPoints(point1 : CLLocationCoordinate2D, point2 : CLLocationCoordinate2D) -> Double {

        let lat1 = deg2rad(point1.latitude)
        let lon1 = deg2rad(point1.longitude)

        let lat2 = deg2rad(point2.latitude)
        let lon2 = deg2rad(point2.longitude)

        let dLon = lon2 - lon1

        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)

        return radiansToDegrees(radians: radiansBearing)
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
        if let marker = annotation as? StopMarker {
            color = marker.color
        }
        view.markerTintColor = color
        return view
    }}
