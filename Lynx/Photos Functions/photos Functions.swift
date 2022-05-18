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


func getPhotosIDs(location: Location, start: Date, end: Date)->[String]{
    var ids: [String] = []
    let fetchOptions = PHFetchOptions()
    fetchOptions.predicate = NSPredicate(format: "creationDate > %@ AND creationDate < %@", start as CVarArg, end as CVarArg)
    let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: location.photoIDs, options: fetchOptions)
    if fetchResult.count > 0 {
        for index in 0  ..< fetchResult.count  {
            let asset = fetchResult.object(at: index)
            ids.append(asset.localIdentifier)
        }
    }
    return ids
}


func selectPhotosIDs(ids: [String], start: Date, end: Date)->[String]{
    var ids: [String] = []
    let fetchOptions = PHFetchOptions()
    fetchOptions.predicate = NSPredicate(format: "creationDate > %@ AND creationDate < %@", start as CVarArg, end as CVarArg)
    let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: ids, options: fetchOptions)
    if fetchResult.count > 0 {
        for index in 0  ..< fetchResult.count  {
            let asset = fetchResult.object(at: index)
            ids.append(asset.localIdentifier)
        }
    }
    return ids
}
