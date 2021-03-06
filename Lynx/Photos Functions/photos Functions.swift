//
//  photos Functions.swift
//  Lynx
//
//  Created by Pietro on 15/05/22.
//

import UIKit
import Photos




func getPhotoIDs(lat: Double, lon: Double, all: Bool)->[String] {
    var startDate: Date!, endDate: Date!
    if all {startDate = Date(timeIntervalSince1970: 1622509261); endDate = Date.now}
    if !all {startDate = sharedData.shared.startDate; endDate = sharedData.shared.endDate}
    var ids: [String] = []
    // Fetch the images between the start and end date
    let fetchOptions = PHFetchOptions()
    fetchOptions.predicate = NSPredicate(format: "creationDate > %@ AND creationDate < %@", startDate as CVarArg, endDate as CVarArg)
    let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
    if fetchResult.count > 0 {
        for index in 0 ..< fetchResult.count  {
            let asset = fetchResult.object(at: index)
            if let distance = asset.location?.distance(from: CLLocation(latitude: lat, longitude: lon)){
                if distance > Constants.shared.same_photo_place_distance {continue}
                ids.append(asset.localIdentifier)
                continue
            }
        }
    }
    return ids
}



func selectPhotosIDs(ids: [String], start: Date, end: Date)->[String]{
    let start = NSDate(timeIntervalSince1970: start.timeIntervalSince1970)
    let end = NSDate(timeIntervalSince1970: end.timeIntervalSince1970)
    var return_ids: [String] = []
    let fetchOptions = PHFetchOptions()
    fetchOptions.predicate = NSPredicate(format: "creationDate > %@ AND creationDate < %@", start, end)
    let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: ids, options: fetchOptions)
    if fetchResult.count > 0 {
        for index in 0  ..< fetchResult.count  {
            let asset = fetchResult.object(at: index)
            return_ids.append(asset.localIdentifier)
        }
    }
    return return_ids
}

func getUniqueWithPhotos(locations: [Location])->[Location]{
    var locations = locations.filter({!$0.photoIDs.isEmpty})
    locations = locations.filter({$0.name != Constants.shared.defaultLocationName})
    var uniqueLocations: [Location] = []
    var orderedLocations: [Location] = []
    for location in locations {
        if var new_location = locations.first(where: {$0.name == location.name}){
            new_location.photoIDs = selectPhotosIDs(ids: location.photoIDs, start: sharedData.shared.startDate, end: sharedData.shared.endDate)
            uniqueLocations.append(new_location)
        }
        locations.removeAll(where: {$0.name == location.name})
        
    }
    for point in select_points(points: sharedData.shared.points, from: sharedData.shared.startDate, to: sharedData.shared.endDate) {
        if let (index, _) = select_location(coordinates: point.coordinate, locations: uniqueLocations){
            orderedLocations.append(uniqueLocations.remove(at: index))
        }
    }
    orderedLocations = orderedLocations.filter({!$0.photoIDs.isEmpty})
    return orderedLocations
}
