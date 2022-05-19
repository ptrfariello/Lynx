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





class photos_Table_View_Controller: UITableViewController {

    var locations: [Location] = sharedData.shared.locations
    var old_start: Date!
    var old_end: Date!
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locations = getUniqueWithPhotos(locations: locations)
        self.tableView.rowHeight = 200.0
        self.old_start = sharedData.shared.startDate
        self.old_end = sharedData.shared.endDate
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let old = locations.count
        let new = getUniqueWithPhotos(locations: sharedData.shared.locations)
        if new.count != old {
            locations = new
            self.tableView.reloadData()
        }
        if self.old_start != sharedData.shared.startDate || self.old_end != sharedData.shared.endDate{
            self.old_start = sharedData.shared.startDate
            self.old_end = sharedData.shared.endDate
            self.tableView.reloadData()
        }
        if locations.count < 1{
            showNoPhotosAlert()
        }
    }
    
    func showNoPhotosAlert() {
        let alert = UIAlertController(title: "No Photos to show", message: "There are no photos for the selected dates", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { _ in
            //Cancel Action
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if let destination = segue.destination as? photosCollectionViewController,
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "photosCell", for: indexPath) as! placesPhotosTableCell
        cell.create(place: locations[indexPath.row])
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
