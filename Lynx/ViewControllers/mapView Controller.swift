//
//  mapView Controller.swift
//  Lynx
//
//  Created by Pietro on 04/05/22.
//

import UIKit
import MapKit

class mapViewController: UIViewController {

    // MARK: - Connections to StoryBoard
    @IBOutlet weak var mrkCloseBtn: UIButton!
    @IBOutlet private var mapView: MKMapView!
    @IBOutlet weak var markerLabel: UILabel!
    @IBOutlet weak var markerText: UITextView!
    @IBOutlet weak var loadingWheel: UIActivityIndicatorView!
    @IBOutlet weak var milesLabel: UILabel!
    @IBAction func mrkBtnClicked(_ sender: Any) {
        show_marker_info(opt: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        main(url: "coords", start: "2022-04-01", end: "2022-05-30")
    }
    
    func main(url: String, start: String, end: String){
        Task{
            do{
                var points = try await getData(url: url, start: start, end: end)
                points = delete_imp(points: points, num: 6, min_dist: 0.01, angle: 10, s: 50)
                let path = points.map { $0.getCoord()}
                drawPath(path: path)
                let result = markers(points: points)
                let markers = marker_return(markers: result.0)
                let total_dist = Int(result.1)
                milesLabel.text = "\(total_dist) miles"
                drawBoat(points: points)
                loadingWheel.stopAnimating()
                milesLabel.isHidden = false
                mapView?.addAnnotations(markers)
            }
        }
    }
    
    func drawBoat(points: [Place]){
        let boat_place = points.last
        if points.last == nil{return}
        boat_place?.title = print_date(date: boat_place!.time, hour: true)
        let boat = (boat_place ?? Place(time: Date.now, sog: 0, cog: 0, lat: 37.695670, lon: 24.060816, tws: 0, twa: 0, twd: 0)) as MKAnnotation
        mapView.addAnnotation(boat)
    }

    func drawPath(path: [CLLocationCoordinate2D]) {
        mapView?.delegate = self
        var path = path
        let maxLat = Double(path.map(\.latitude).max() ?? 37.759779)
        let maxLong = Double(path.map(\.longitude).max() ?? 24.140416)
        let minLat = Double(path.map(\.latitude).min() ?? 37.642514)
        let minLong = Double(path.map(\.longitude).min() ?? 24.010306)
        
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
    
    func show_marker_info(opt: Bool){
        markerText.isHidden = opt
        markerLabel.isHidden = opt
        mrkCloseBtn.isHidden = opt
    }
}


extension mapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.orange
            renderer.lineWidth = 2
            return renderer
        
        }
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? Marker {
            markerText.text = annotation.print_info()
            markerLabel.text = ""
            if (annotation.coordinate.latitude == 37.695670){
                markerLabel.text = "Fast Sailing, Olympic Marine"
            }else{
            geoCode(location: annotation.coordinate, marker_text: markerLabel)
            }
            show_marker_info(opt: false)
        }
    }
    
}

