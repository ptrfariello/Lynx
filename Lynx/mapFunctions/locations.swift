//
//  locations.swift
//  Lynx
//
//  Created by Pietro on 16/05/22.
//

import Foundation
import MapKit

struct Location: Codable{
    var lat = 0.0
    var lon = 0.0
    var locationName = ""
    var photoIDs: [String] = []
    
    init(coord: CLLocationCoordinate2D, name: String){
        self.lat = coord.latitude
        self.lon = coord.longitude
        self.locationName = name
    }
}

func select_location(coordinates: CLLocationCoordinate2D, locations: [Location])->(Int, Location)?{
    let markerLocation = MKMapPoint(coordinates)
    for (index, location) in locations.enumerated() {
        let locCoord =  MKMapPoint(CLLocationCoordinate2D(latitude: location.lat, longitude: location.lon))
        if markerLocation.distance(to: locCoord)*Constants.shared.meters_to_nm < Constants.shared.sameSpotDistance{
            return (index, location)
        }
    }
    return nil
}

func createLocations(markers: [StopMarker]){
    if sharedData.shared.locations.isEmpty{
        sharedData.shared.locations.append(Constants.shared.fast_sailing_location)
    }
    let markers = marker_return(markers: markers)
    for marker in markers {
        if select_location(coordinates: marker.coordinate, locations: sharedData.shared.locations) != nil{continue}
        sharedData.shared.locations.append(Location(coord: marker.coordinate, name: ""))
    }
    updateLocationPhotos(all: false)
    updateLocationNames()
}


func updateLocationNames(){
    Task {
        for location in sharedData.shared.locations.reversed() {
            _ = await geoCode(lat: location.lat, lon: location.lat)
            sleep(1)
            }
        }
    }

func updateLocationPhotos(all: Bool){
    Task{
        for i in sharedData.shared.locations.indices {
            let location = sharedData.shared.locations[i]
            let ids = getPhotoIDs(lat: location.lat, lon: location.lon, all: all)
            if ids.isEmpty{continue}
            sharedData.shared.locations[i].photoIDs.append(contentsOf: ids)
            sharedData.shared.locations[i].photoIDs = Array(Set(sharedData.shared.locations[i].photoIDs))
        }
    }
}
