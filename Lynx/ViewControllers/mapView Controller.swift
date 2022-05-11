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
    @IBOutlet weak var milesLabel: UILabel!
    @IBOutlet weak var mrkCloseBtn: UIButton!
    @IBOutlet private var mapView: MKMapView!
    @IBOutlet weak var markerLabel: UILabel!
    @IBOutlet weak var markerText: UITextView!
    @IBOutlet weak var loadingWheel: UIActivityIndicatorView!
    
    @IBAction func goToPlaceTap(_ sender: UITapGestureRecognizer) {
        showOpenMapsAlert()
    }
    
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBAction func mrkBtnClicked(_ sender: Any) {
        hide_marker_info(opt: true)
    }
    
    var active_Marker: Marker?
    
    var start: Date = Date.now.addingTimeInterval(-3600*24*28)
    var end: Date = Date.now
    
    var points: [Place] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView?.delegate = self
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        get_and_update()
        main(points: points, start: start, end: end)
    }
    
    func main(points: [Place], start: Date, end: Date){
        mapClear()
        startDateLabel.text = "" //"\(print_date(date: start, hour: false))"
        endDateLabel.text = "" //"\(print_date(date: end, hour: false))"
        let data_present = points.count > 3
        let points = select_points(points: points, from: start, to: end)
        if data_present && points.count < 3{
            print(data_present, points.count<3)
            showNoDataAlert()
        }
        let path = points.map{ $0.getCoord()}
        drawPath(path: path)
        let result = markers(points: points)
        let markers = marker_return(markers: result.0)
        let total_dist = Int(result.1)
        milesLabel.text = "\(total_dist) miles"
        milesLabel.isHidden = false
        drawBoat(points: points)
        loadingWheel.stopAnimating()
        mapView?.addAnnotations(markers)
        if points.count < 3 {showDownloadingAlert(); loadingWheel.startAnimating()}
        draw_data_points()
    }
    
    func showDownloadingAlert() {
        let alert = UIAlertController(title: "Downloading", message: "We are downloading data for the first time, this might take a little while", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { _ in
            //Cancel Action
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showNoDataAlert() {
        let alert = UIAlertController(title: "No Data", message: "There is no data for the selected dates", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { _ in
            //Cancel Action
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showReloadAlert() {
        let alert = UIAlertController(title: "New Data", message: "There is new available data for the selected dates", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { _ in
            //Cancel Action
        }))
        alert.addAction(UIAlertAction(title: "Reload", style: UIAlertAction.Style.default, handler: { [self](_: UIAlertAction!) in
            self.main(points: self.points, start: self.start, end: self.end)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showOpenMapsAlert() {
        let alert = UIAlertController(title: "Open in Maps", message: "Open this location in Maps?", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { _ in
            //Cancel Action
        }))
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: { [self](_: UIAlertAction!) in
            self.open_maps()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func open_maps(){
        let coordinate = active_Marker?.coordinate ?? fast_sailing
        let placemark = MKPlacemark(coordinate: coordinate)
        let map_item = MKMapItem(placemark: placemark)
        map_item.name = markerLabel.text
        map_item.openInMaps()
    }
    
    func mapClear(){
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)
    }
    
    func drawBoat(points: [Place]){
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
    
    func hide_marker_info(opt: Bool){
        if opt {
            markerText.text = ""
            markerLabel.text = ""
        }
        markerText.isHidden = opt
        markerLabel.isHidden = opt
        mrkCloseBtn.isHidden = opt
        startDateLabel.isHidden = opt
        endDateLabel.isHidden = opt
    }
    
    func get_and_update(){
        points = get_saved()
        if points.count < 3 {showDownloadingAlert()}
        Task {
            do{
                let last_point: Date = points.last?.time ?? Date.distantPast
                let updated = try await update_saved(points: self.points)
                if updated{
                    get_and_update()
                    if last_point < end && points.count > 3{
                        showReloadAlert()
                    }
                }
            }
        }
    }
    
    func draw_data_points(){
        let start = date_to_iso(date: start)
        let end = date_to_iso(date: end)
        Task{
            do{
                var temp_place = try await getData(url: "maxSpeed", start: start, end: end)[0]
                var title = "\(myRound(value: temp_place.sog, decimalPlaces: 1.0)) kts"
                let fastest_speed = DataMarker(place: temp_place, color: UIColor.green, title: title)
                
                temp_place = try await getData(url: "maxTWS", start: start, end: end)[0]
                title = "\(myRound(value: temp_place.tws, decimalPlaces: 1.0)) kts"
                let fastest_wind = DataMarker(place: temp_place, color: UIColor.blue, title: title)
                
                temp_place = try await getData(url: "depth", start: start, end: end)[0]
                title = "\(myRound(value: temp_place.depth, decimalPlaces: 1.0)) m"
                let min_depth = DataMarker(place: temp_place, color: UIColor.orange, title: title)
                
                mapView.addAnnotations([fastest_speed, fastest_wind, min_depth])
            }
        }
        
    }

    
    //MARK: - Segue Functions
    @IBAction func cancelToMapViewController(_ segue: UIStoryboardSegue) {
    }
    
    @IBAction func saveDate(_ segue: UIStoryboardSegue) {
        if segue.identifier == "apply_dates"
        {
            if let date_picker = segue.source as? dateSelController
            {
                start = date_picker.startDatePicker.date
                end = date_picker.endDatePicker.date
                main(points: points, start: start, end: end)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "dates_to_picker") {
            if let date_picker = segue.destination as? dateSelController {
                date_picker.start = self.start
                date_picker.end = self.end
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
            active_Marker = annotation
            hide_marker_info(opt: false)
        }
    }
    
    func mapView(_ MapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        var color = UIColor.blue
        if let data_point = annotation as? DataMarker {
            color = data_point.color
        }
        if annotation is Marker{return nil}
        view.markerTintColor = color
        return view
    }
}

