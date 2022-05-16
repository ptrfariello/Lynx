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



class mapViewController: UIViewController, CLLocationManagerDelegate {
    
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
    //MARK: - UI Functions
    func locationButtonFunc(){
        let locManager = CLLocationManager()
        locManager.requestWhenInUseAuthorization()
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
    func hide_marker_info(opt: Bool){
        if opt {
            bottomText.text = ""
            bottomLabel.text = ""
        }
        bottomText.isHidden = opt
        bottomLabel.isHidden = opt
        mrkCloseBtn.isHidden = opt
    }
    
    
    //MARK: - Variable Declaration
    var active_Marker: StopMarker?
    
    var points: [Point] = []
    var markers: [StopMarker] = []
    var routes: [Route] = []
   
    
    //MARK: - Override View Functiona
    override func viewDidLoad() {
        super.viewDidLoad()
        sharedData.shared.startDate = defaults.object(forKey: "startDate") as? Date ?? sharedData.shared.startDate
        sharedData.shared.endDate = defaults.object(forKey: "endDate") as? Date ?? sharedData.shared.endDate
        mapView?.delegate = self
        get_and_update()
        (markers, routes) = getMarkersRoutes(points: points)
        showTrip(points: points, start: sharedData.shared.startDate, end: sharedData.shared.endDate)
        locationButtonFunc()
        show_compass()
        
        createLocations(markers: markers)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if points.count < 3 {loadingWheel.startAnimating(); sleep(1); showDownloadingAlert(); }
    }
    
    
    //MARK: - Main Function
    func showTrip(points: [Point], start: Date, end: Date){
        mapClear()
        let data_present = points.count > 3
        let points = select_points(points: points, from: start, to: end)
        let path = points.map{ $0.getCoord()}
        drawPath(path: path)

        let (markers, routes) = selectMarkersRoutes(markers: markers, routes: routes, start: start, end: end)
        
        let displayMarkers = marker_return(markers: markers)
        
        for (index, marker) in markers.enumerated() {
            if "\(marker.arrival)" == "[2021-08-08 15:25:33 +0000]"{
                print(markers.count, index)
            }
        }
        mapView?.addAnnotations(displayMarkers)
        var tot_dist = 0.0
        for route in routes {
            tot_dist += route.length
        }
        
        milesLabel.text = "\(Int(tot_dist)) miles"
        milesLabel.isHidden = false
        
        drawBoat(points: points)
        
        loadingWheel.stopAnimating()
        
        if data_present && points.count < 3{
            showNoDataAlert()
        }
        draw_data_points(disabled: points.count<3)
    }
    
    
    //MARK: - Alerts
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
            self.showTrip(points: self.points, start: sharedData.shared.startDate, end: sharedData.shared.endDate)
            createLocations(markers: markers)
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
        let coordinate = active_Marker?.coordinate ?? Constants.shared.fast_sailing
        let placemark = MKPlacemark(coordinate: coordinate)
        let map_item = MKMapItem(placemark: placemark)
        map_item.name = bottomLabel.text
        map_item.openInMaps()
    }
    
    
    //MARK: - Map Draw Functions
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
        let boat = (boat_place ?? Point(time: Date.now, coord: Constants.shared.fast_sailing)) as MKAnnotation
        mapView.addAnnotation(boat)
    }
    func drawPath(path: [CLLocationCoordinate2D]) {
        var path = path
        
        let polyline = MKPolyline(coordinates: &path, count: path.count)
        
        mapView.setVisibleMapRect(polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0), animated: false)
       
        self.mapView?.addOverlay(polyline)
        
    }
    func draw_data_points(disabled: Bool){
        if disabled {return}
        let start_string = date_to_iso(date: sharedData.shared.startDate)
        let end_string = date_to_iso(date: sharedData.shared.endDate)
        Task{
            do{
                let fastest_speed = try await getData(url: "maxSpeed", start: start_string, end: end_string)[0]
                
                var title = "\(myRound(value: fastest_speed.sog, decimalPlaces: 1.0)) kts"
                var to_print = "The fastest speed over a minute between \(print_date(date: sharedData.shared.startDate, hour: false)) and \(print_date(date: sharedData.shared.endDate, hour: false)) was \(title) on \(print_date(date: fastest_speed.time, hour: true)) with \(myRound(value: fastest_speed.tws, decimalPlaces: 1.0)) kts of wind"
                
                fastest_speed.color = UIColor.green; fastest_speed.title = title
                fastest_speed.to_print = to_print
                
                
                let fastest_wind = try await getData(url: "maxTWS", start: start_string, end: end_string)[0]
                
                title = "\(myRound(value: fastest_wind.tws, decimalPlaces: 1.0)) kts"
                to_print = "The fastest True Wind Speed between \(print_date(date: sharedData.shared.startDate, hour: false)) and \(print_date(date: sharedData.shared.endDate, hour: false)) was \(title) on \(print_date(date: fastest_wind.time, hour: true))"
                
                fastest_wind.color = UIColor.blue; fastest_wind.title = title
                fastest_wind.to_print = to_print
                
                let min_depth = try await getData(url: "depth", start: start_string, end: end_string)[0]
                
                to_print = "The minimum depth between \(print_date(date: sharedData.shared.startDate, hour: false)) and \(print_date(date: sharedData.shared.endDate, hour: false)) was \(title) on \(print_date(date: fastest_speed.time, hour: true))"
                title = "\(myRound(value: min_depth.depth, decimalPlaces: 1.0)) m"
                
                min_depth.color = UIColor.orange; min_depth.title = title
                min_depth.to_print = to_print
                
                
                mapView.addAnnotations([fastest_speed, fastest_wind, min_depth])
            }
        }
        
    }
    
    
    //MARK: - Loading and Updating Saved Data
    let defaults = UserDefaults.standard
    func get_and_update(){
        self.points = get_saved_points()
        Task {
            do{
                let last_point: Date = self.points.last?.time ?? Date.distantPast
                let updated = try await update_saved_points(points: self.points)
                if updated{
                    get_and_update()
                    (self.markers, self.routes) = getMarkersRoutes(points: self.points)
                    if last_point < sharedData.shared.endDate && self.points.count > 3{
                        showReloadAlert()
                    }
                }
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
                date_picker.dismiss(animated: true)
                sharedData.shared.startDate = date_picker.startDatePicker.date
                sharedData.shared.endDate = date_picker.endDatePicker.date
                showTrip(points: points, start: sharedData.shared.startDate, end: sharedData.shared.endDate)
                defaults.set(sharedData.shared.startDate, forKey: "startDate")
                defaults.set(sharedData.shared.endDate, forKey: "endDate")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "show_routes") {
            if let navController = segue.destination as? UINavigationController{
                if let routes_view = navController.viewControllers[0] as? routesTableViewController {
                    routes_view.routes = select_routes(routes: self.routes, from: sharedData.shared.startDate, to: sharedData.shared.endDate)
                    routes_view.points = select_points(points: self.points, from: sharedData.shared.startDate, to: sharedData.shared.endDate)
                }
            }
        }
    }
}


//MARK: - Map View Delegate Extentions
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
                stopMarker.getLocationName(savedLocation: sharedData.shared.locations)
                stopMarker.locationName = await stopMarker.locationName != "" ? stopMarker.locationName : geoCode(lat: stopMarker.coordinate.latitude, lon: stopMarker.coordinate.longitude)
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

