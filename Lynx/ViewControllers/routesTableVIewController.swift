//
//  routesTableVIewController.swift
//  Lynx
//
//  Created by Pietro on 13/05/22.
//

import UIKit

let startColor = UIColor.red
let endColor = UIColor.orange

class routesTableVIewController: UITableViewController {

    var routes: [Route] = []
    var points: [Point] = []
    var locationNames: [geocodedLocation] = get_saved_locations()
    var fastest = 0
    var longest = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        var maxSpeed: Float = 0.0, maxDist = 0.0
        for (i, route) in routes.enumerated() {
            if route.avgSpeed > maxSpeed {fastest = i; maxSpeed = route.avgSpeed}
            if route.length > maxDist{longest = i; maxDist = route.length}
            route.startPoint.getLocationName(savedLocation: locationNames)
            route.endPoint.getLocationName(savedLocation: locationNames)
            route.loadData()
        }
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
        var title = "Route \(indexPath.row+1) - \(Int(myRound(value: Float(route.length), decimalPlaces: 0))) miles"
        if indexPath.row == fastest {title += " - FASTEST"}
        if indexPath.row == longest {title += " - LONGEST"}
        
        var description = ""
        if route.startPoint.locationName != ""{
            description = " in \(route.startPoint.locationName)"
        }
        description = "Started on \(print_date(date: route.start, hour: true))\(description)\nFinished on \(print_date(date: route.end, hour: true))"
        if route.endPoint.locationName != ""{
            description += " in \(route.endPoint.locationName)"
        }
        
        route.startPoint.color = startColor; route.endPoint.color = endColor
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
