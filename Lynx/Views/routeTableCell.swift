//
//  routeTableCell.swift
//  Lynx
//
//  Created by Pietro on 13/05/22.
//

import UIKit
import MapKit

class routeTableCell: UITableViewCell, MKMapViewDelegate {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    @IBOutlet weak var routeName: UILabel!
    @IBOutlet weak var routeMap: MKMapView!
    @IBOutlet weak var routeDescription: UITextView!
    @IBOutlet weak var routeCellMapview: MKMapView!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(name: String, description: String, route: Route, points: [Point]){
        routeCellMapview?.delegate = self
        routeName.text = name
        routeDescription.text = description
        drawRoute(route: route, points: points)
    }
    
    func mapClear(){
        let overlays = routeCellMapview.overlays
        routeCellMapview.removeOverlays(overlays)
        let annotations = routeCellMapview.annotations
        routeCellMapview.removeAnnotations(annotations)
    }
    
    //MARK: - Map Functions
    func drawRoute(route: Route, points: [Point]) {
        mapClear()
        let points = select_points(points: points, from: route.start, to: route.end)
        let path = points.map{ $0.getCoord()}
        
        let start = path.first ?? fast_sailing
        let end = path.last ?? fast_sailing
        
        let maxLat = Double(path.map(\.latitude).max() ?? 37.759779)
        let maxLong = Double(path.map(\.longitude).max() ?? 24.140416)
        let minLat = Double(path.map(\.latitude).min() ?? 37.642514)
        let minLong = Double(path.map(\.longitude).min() ?? 24.010306)
        let centerLat = (maxLat + minLat) / 2
        let centerLon = (maxLong + minLong) / 2
        
        let center = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon)
        let heading = getBearingBetweenTwoPoints(point1: end, point2: start)
        let start_CL = CLLocation(latitude: start.latitude, longitude: start.longitude)
        let end_CL = CLLocation(latitude: end.latitude, longitude: end.longitude)
        let distance_calc = start_CL.distance(from: end_CL)
        let polyline = MKPolyline(coordinates: path, count: path.count)
        self.routeCellMapview?.addOverlay(polyline)
        routeCellMapview.addAnnotations([route.endMarker, route.startMarker])
        routeCellMapview.setVisibleMapRect(polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0), animated: false)
        let distance_visible_rect = routeCellMapview.camera.centerCoordinateDistance
    
        let orientation = abs((90-abs(heading))/90)
        let distance = distance_visible_rect*orientation + distance_calc*(1-orientation)
        self.routeCellMapview.camera = MKMapCamera(lookingAtCenter: center, fromDistance: distance, pitch: 0, heading: heading+90)
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
    }

}
