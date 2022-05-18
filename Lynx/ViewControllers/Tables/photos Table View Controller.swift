//
//  photos Table View Controller.swift
//  Lynx
//
//  Created by Pietro on 15/05/22.
//

import UIKit
import Photos
import PhotosUI
import MapKit



func getUniqueWithPhotos(locations: [Location])->[Location]{
    var locations = locations.filter({!$0.photoIDs.isEmpty})
    var uniqueLocations: [Location] = []
    var orderedLocations: [Location] = []
    for var location in locations {
        location.photoIDs = selectPhotosIDs(ids: location.photoIDs, start: sharedData.shared.startDate, end: sharedData.shared.startDate)
        if location.locationName == Constants.shared.defaultLocationName {
            uniqueLocations.append(location)
            continue
        }
        if let new = locations.first(where: {$0.locationName == location.locationName}){
            uniqueLocations.append(new)
        }
        locations.removeAll(where: {$0.locationName != Constants.shared.defaultLocationName && $0.locationName == location.locationName})
    }
    for point in select_points(points: sharedData.shared.points, from: sharedData.shared.startDate, to: sharedData.shared.endDate) {
        if let (index, _) = select_location(coordinates: point.coordinate, locations: uniqueLocations){
            orderedLocations.append(uniqueLocations.remove(at: index))

        }
    }
    return orderedLocations
}

class photos_Table_View_Controller: UITableViewController {

    var places: [PlaceCell] = []
    var locations: [Location] = sharedData.shared.locations
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locations = getUniqueWithPhotos(locations: locations)
        self.tableView.rowHeight = 200.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let old = locations.count
        let new = getUniqueWithPhotos(locations: sharedData.shared.locations)
        if new.count != old {
            locations = new
            self.tableView.reloadData()
        }
        for place in places {
            if place.place.locationName != Constants.shared.defaultLocationName {continue}
            if let location = locations.first(where: {$0.lat == place.place.lat && $0.lon == place.place.lon}){
                place.place.locationName = location.locationName
            }
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if let destination = segue.destination as? placePhotoViewController,
        let indexPath = tableView.indexPathForSelectedRow {
          destination.location = locations[indexPath.row]
      }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "photosCell", for: indexPath) as! placePhotosCell
        let i = indexPath.row
        if i > places.count-1 {
            places.append(PlaceCell(place: locations[i]))
        }
        cell.create(place: places[indexPath.row])
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
