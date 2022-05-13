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
        for route in routes {
            print(route.endMarker.color)
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

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "routeCell", for: indexPath) as? routeTableCell ?? routeTableCell(style: .default, reuseIdentifier: "routeCell")

        let route = routes[indexPath.row]
        let title = "\(myRound(value: Float(route.length), decimalPlaces: 0)) miles"
        let description = "Started on \(print_date(date: route.start, hour: true)) in \(route.startMarker.locationName)\nEnded on \(print_date(date: route.end, hour: true)) in \(route.endMarker.locationName)"
        cell.configure(name: title, description: description, route: route, points: points)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Section \(section)"
    }


}
