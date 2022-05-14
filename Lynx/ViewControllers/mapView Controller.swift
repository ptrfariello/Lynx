//
//  mapView Controller.swift
//  Lynx
//
//  Created by Pietro on 04/05/22.
//

import UIKit
import MapKit
import CoreLocationUI
import CoreLocation

let fast_sailing = CLLocationCoordinate2D(latitude: 37.695670, longitude: 24.060816)

class mapViewController: UIViewController, CLLocationManagerDelegate {
    
    let defaults = UserDefaults.standard
    
    // MARK: - Connections to StoryBoard
    @IBOutlet weak var milesLabel: UILabel!
    @IBOutlet weak var mrkCloseBtn: UIButton!
    @IBOutlet private var mapView: MKMapView!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var bottomText: UITextView!
    @IBOutlet weak var loadingWheel: UIActivityIndicatorView!
    @IBAction func goToPlaceTap(_ sender: UITapGestureRecognizer) {
        showOpenMapsAlert()
    }
    @IBAction func mrkBtnClicked(_ sender: Any) {
        hide_marker_info(opt: true)
    }
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var locationButtonView: UIView!
    @IBOutlet weak var compassView: UIView!
    
    var active_Marker: StopMarker?
    var start: Date = Date.now.addingTimeInterval(-3600*24*14)
    var end: Date = Date.now
    var points: [Point] = []
    var routes: [Route] = []
    var locations: [geocodedLocation] = []
    
    func locationButtonFunc(){
        let locationButton = MKUserTrackingButton(mapView: mapView)
        buttonView.layer.cornerRadius = 10
        locationButtonView.addSubview(locationButton)
        locationButton.tintColor = UIColor.darkGray
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        locationButton.topAnchor.constraint(equalTo: locationButtonView.topAnchor).isActive = true
        locationButton.bottomAnchor.constraint(equalTo: locationButtonView.bottomAnchor).isActive = true
        locationButton.leadingAnchor.constraint(equalTo: locationButtonView.leadingAnchor).isActive = true
        locationButton.trailingAnchor.constraint(equalTo: locationButtonView.trailingAnchor).isActive = true
    }
    func show_compass(){
        let compass = MKCompassButton(mapView: mapView)
        compassView.addSubview(compass)
        compass.compassVisibility = .adaptive
        compass.translatesAutoresizingMaskIntoConstraints = false
        compass.topAnchor.constraint(equalTo: compassView.topAnchor).isActive = true
        compass.leadingAnchor.constraint(equalTo: compassView.leadingAnchor).isActive = true
        compassView.backgroundColor = UIColor.clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        start = defaults.object(forKey: "startDate") as? Date ?? start
        end = defaults.object(forKey: "endDate") as? Date ?? end
        mapView?.delegate = self
        get_and_update()
        locations = get_saved_locations()
        main(points: points, start: start, end: end)
        locationButtonFunc()
        show_compass()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func main(points: [Point], start: Date, end: Date){
        mapClear()
        let data_present = points.count > 3
        let points = select_points(points: points, from: start, to: end)
        let path = points.map{ $0.getCoord()}
        drawPath(path: path)
        
        let result = markers(points: points)
        let markers = result.0
        updateMarkers(markers: markers)
        let displayMarkers = marker_return(markers: markers)
        mapView?.addAnnotations(displayMarkers)
        
        routes = getRoutes(markers: markers, lengths: result.1)
        
        let total_dist = Int(result.2)
        milesLabel.text = "\(total_dist) miles"
        milesLabel.isHidden = false
        
        drawBoat(points: points)
        
        loadingWheel.stopAnimating()
        
        if data_present && points.count < 3{
            showNoDataAlert()
        }
        draw_data_points(disabled: points.count<3)
        
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
        map_item.name = bottomLabel.text
        map_item.openInMaps()
    }
    
    func mapClear(){
        let overlays = mapView.overlays
        mapView.removeOverlays(overlays)
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)
    }
    
    func drawBoat(points: [Point]){
        let boat_place = points.last
        if points.last == nil{return}
        boat_place?.title = print_date(date: boat_place!.time, hour: true)
        let boat = (boat_place ?? Point(time: Date.now, coord: fast_sailing)) as MKAnnotation
        mapView.addAnnotation(boat)
    }
    
    func drawPath(path: [CLLocationCoordinate2D]) {
        var path = path
        
        let polyline = MKPolyline(coordinates: &path, count: path.count)
        
        mapView.setVisibleMapRect(polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0), animated: false)
       
        self.mapView?.addOverlay(polyline)
        
    }
    
    func hide_marker_info(opt: Bool){
        if opt {
            bottomText.text = ""
            bottomLabel.text = ""
        }
        bottomText.isHidden = opt
        bottomLabel.isHidden = opt
        mrkCloseBtn.isHidden = opt
    }
    
    func get_and_update(){
        points = get_saved_points()
        if points.count < 3 {loadingWheel.startAnimating(); sleep(1); showDownloadingAlert(); }
        Task {
            do{
                let last_point: Date = points.last?.time ?? Date.distantPast
                let updated = try await update_saved_points(points: self.points)
                if updated{
                    get_and_update()
                    if last_point < end && points.count > 3{
                        showReloadAlert()
                    }
                }
            }
        }
    }
    
    func updateMarkers(markers: [StopMarker]){
        DispatchQueue.global().async {
            for marker in markers{
                marker.getLocationName(savedLocation: self.locations)
                usleep(1000000/2)
            }
        }
    }
    
    func draw_data_points(disabled: Bool){
        if disabled {return}
        let start_string = date_to_iso(date: start)
        let end_string = date_to_iso(date: end)
        Task{
            do{
                let fastest_speed = try await getData(url: "maxSpeed", start: start_string, end: end_string)[0]
                
                var title = "\(myRound(value: fastest_speed.sog, decimalPlaces: 1.0)) kts"
                var to_print = "The fastest speed over a minute between \(print_date(date: start, hour: false)) and \(print_date(date: end, hour: false)) was \(title) on \(print_date(date: fastest_speed.time, hour: true)) with \(myRound(value: fastest_speed.tws, decimalPlaces: 1.0)) kts of wind"
                
                fastest_speed.color = UIColor.green; fastest_speed.title = title
                fastest_speed.to_print = to_print
                
                
                let fastest_wind = try await getData(url: "maxTWS", start: start_string, end: end_string)[0]
                
                title = "\(myRound(value: fastest_wind.tws, decimalPlaces: 1.0)) kts"
                to_print = "The fastest True Wind Speed between \(print_date(date: start, hour: false)) and \(print_date(date: end, hour: false)) was \(title) on \(print_date(date: fastest_wind.time, hour: true))"
                
                fastest_wind.color = UIColor.blue; fastest_wind.title = title
                fastest_wind.to_print = to_print
                
                let min_depth = try await getData(url: "depth", start: start_string, end: end_string)[0]
                
                to_print = "The minimum depth between \(print_date(date: start, hour: false)) and \(print_date(date: end, hour: false)) was \(title) on \(print_date(date: fastest_speed.time, hour: true))"
                title = "\(myRound(value: min_depth.depth, decimalPlaces: 1.0)) m"
                
                min_depth.color = UIColor.orange; min_depth.title = title
                min_depth.to_print = to_print
                
                
                mapView.addAnnotations([fastest_speed, fastest_wind, min_depth])
            }
        }
        
    }

    
    //MARK: - User Location

    
    //MARK: - Segue Functions
    @IBAction func cancelToMapViewController(_ segue: UIStoryboardSegue) {
    }
    
    @IBAction func saveDate(_ segue: UIStoryboardSegue) {
        if segue.identifier == "apply_dates"
        {
            if let date_picker = segue.source as? dateSelController
            {
                date_picker.dismiss(animated: true)
                start = date_picker.startDatePicker.date
                end = date_picker.endDatePicker.date
                main(points: points, start: start, end: end)
                defaults.set(start, forKey: "startDate")
                defaults.set(end, forKey: "endDate")
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
        if (segue.identifier == "show_routes") {
            if let navController = segue.destination as? UINavigationController{
                if let routes_view = navController.viewControllers[0] as? routesTableVIewController {
                    routes_view.routes = routes
                    routes_view.points = points
                }
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
        if let stopMarker = view.annotation as? StopMarker {
            bottomText.text = stopMarker.print_info()
            bottomLabel.text = ""
            Task{do{
                stopMarker.getLocationName(savedLocation: locations)
                bottomLabel.text = stopMarker.locationName
                active_Marker = stopMarker
                hide_marker_info(opt: false)
            }}
            
        }
        else if let point = view.annotation as? Point {
            bottomText.text = point.to_print
            bottomLabel.text = point.title
            hide_marker_info(opt: false)
        }
    }
    
    func mapView(_ MapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let _ = annotation as? MKUserLocation {return nil}
        let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        var color = UIColor.blue
        if let data_point = annotation as? Point {
            color = data_point.color
        }
        if annotation is StopMarker{return nil}
        view.markerTintColor = color
        return view
    }
    
}

