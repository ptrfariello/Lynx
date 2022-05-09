//
//  mapView Controller.swift
//  Lynx
//
//  Created by Pietro on 04/05/22.
//

import UIKit
import MapKit

let fast_sailing = CLLocationCoordinate2D(latitude: 37.695670, longitude: 24.060816)

class mapViewController: UIViewController {
    
    // MARK: - Connections to StoryBoard
    @IBOutlet weak var mrkCloseBtn: UIButton!
    @IBOutlet private var mapView: MKMapView!
    @IBOutlet weak var markerLabel: UILabel!
    @IBOutlet weak var markerText: UITextView!
    @IBOutlet weak var loadingWheel: UIActivityIndicatorView!
    @IBOutlet weak var milesLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBAction func mrkBtnClicked(_ sender: Any) {
        show_marker_info(opt: true)
    }
    @IBAction func srtBtnClicked(_ sender: Any) {
        
    }
    
    
    var start: Date = Date.now.addingTimeInterval(-3600*24*14)
    var end: Date = Date.now
    
    var points: [Place] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        get_and_update()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        main(points: points, start: start, end: end)
    }
    
    func main(points: [Place], start: Date, end: Date){
        mapClear()
        startDateLabel.text = "\(print_date(date: start, hour: false))"
        endDateLabel.text = "\(print_date(date: end, hour: false))"
        let points = select_points(points: points, from: start, to: end)
        let path = points.map{ $0.getCoord()}
        drawPath(path: path)
        let result = markers(points: points)
        let markers = marker_return(markers: result.0)
        let total_dist = Int(result.1)
        
        milesLabel.text = "\(total_dist) nm"
        drawBoat(points: points)
        loadingWheel.stopAnimating()
        milesLabel.isHidden = false
        mapView?.addAnnotations(markers)
    }
    
    func mapClear(){
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)
    }
    
    func drawBoat(points: [Place]){
        mapView?.delegate = self
        let boat_place = points.last
        if points.last == nil{return}
        boat_place?.title = print_date(date: boat_place!.time, hour: true)
        let boat = (boat_place ?? Place(time: Date.now, coord: fast_sailing)) as MKAnnotation
        mapView.addAnnotation(boat)
    }
    
    func drawPath(path: [CLLocationCoordinate2D]) {
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
        startDateLabel.isHidden = opt
        endDateLabel.isHidden = opt
    }
    
    func get_and_update(){
        points = get_saved()
        Task {
            do{
                let updated = try await update_saved(points: self.points)
                if updated{
                    get_and_update()
                }
            }
        }
    }
    
    
    //MARK: - Segue Functions
    @IBAction func cancelToMapViewController(_ segue: UIStoryboardSegue) {
    }
    
    @IBAction func saveDate(_ segue: UIStoryboardSegue) {
        if segue.identifier == "start"
        {
            if let date_picker = segue.source as? dateSelController
            {
                start = date_picker.startDatePicker.date
                end = date_picker.endDatePicker.date
                main(points: points, start: start, end: end)
            }
        }
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
    
    func mapView(_ MapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        if annotation is Marker {
            return nil
        }
        view.markerTintColor = .blue
        return view
    }
}

