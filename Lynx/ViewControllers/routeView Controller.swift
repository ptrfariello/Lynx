//
//  routesView Controller.swift
//  Lynx
//
//  Created by Pietro on 13/05/22.
//

import Foundation
import UIKit
import MapKit

class routeViewController: UIViewController, MKMapViewDelegate {
    var points: [Point] = []
    var routes: [Route] = []
    
    
    @IBOutlet weak var routeMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        routeMapView?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        drawRoute(route: routes[5])
    }
    
    
    func mapClear(){
        let overlays = routeMapView.overlays
        routeMapView.removeOverlays(overlays)
        let annotations = routeMapView.annotations
        routeMapView.removeAnnotations(annotations)
    }
    
    func drawRoute(route: Route) {
        mapClear()
        let points = select_points(points: points, from: route.start, to: route.end)
        let path = points.map{ $0.getCoord()}
        let start = path.first ?? fast_sailing
        let end = path.last ?? fast_sailing
        
        let centerLat = (start.latitude+end.latitude)/2
        let centerLon = (start.longitude+end.longitude)/2
        let center = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon)
        
        let heading = getBearingBetweenTwoPoints(point1: start, point2: end)
        let start_CL = CLLocation(latitude: start.latitude, longitude: start.longitude)
        let end_CL = CLLocation(latitude: end.latitude, longitude: end.longitude)
        
        let distance = start_CL.distance(from: end_CL)
        
        self.routeMapView.camera = MKMapCamera(lookingAtCenter: center, fromDistance: distance, pitch: 0, heading: heading+90)
        //self.routeMapView.setRegion(region, animated: true)
        let polyline = MKPolyline(coordinates: path, count: path.count)
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
}
