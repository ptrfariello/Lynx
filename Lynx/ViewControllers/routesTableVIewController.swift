//
//  routesTableVIewController.swift
//  Lynx
//
//  Created by Pietro on 13/05/22.
//

import UIKit

class routesTableVIewController: UITableViewController {

    var routes: [Route] = []
    var points: [Point] = []
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return routes.count
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection
                                section: Int) -> String? {
        return "\(routes.count) Routes"
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "routeCell", for: indexPath) as? routeTableCell ?? routeTableCell(style: .default, reuseIdentifier: "routeCell")

        let route = routes[indexPath.row]
        let title = "Route \(indexPath.row+1) - \(myRound(value: Float(route.length), decimalPlaces: 0)) miles"
        
        var description = ""
        if route.startMarker.locationName != ""{
            description = " in \(route.startMarker.locationName)"
        }
        description = "Started on \(print_date(date: route.start, hour: true)) \(description)\nFinished on \(print_date(date: route.end, hour: true))"
        if route.endMarker.locationName != ""{
            description += " in \(route.endMarker.locationName)"
        }
        
        route.startMarker.color = UIColor.green; route.endMarker.color = UIColor.blue
        cell.configure(name: title, description: description, route: route, points: points)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if let destination = segue.destination as? routeDetailViewController,
        let indexPath = tableView.indexPathForSelectedRow {
        destination.route = routes[indexPath.row]
        destination.points = points
      }
    }


}
