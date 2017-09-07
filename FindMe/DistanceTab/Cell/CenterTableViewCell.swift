//
//  CenterTableViewCell.swift
//  FindMe
//
//  Created by Sébastien Brugalières on 27/08/2017.
//  Copyright © 2017 Sébastien Brugalières. All rights reserved.
//

import UIKit
import MapKit

class CenterTableViewCell: UITableViewCell {

    @IBOutlet weak var theLatitude: UILabel!
    @IBOutlet weak var theLongitude: UILabel!

    @IBOutlet weak var theMarker: CenterPinViewAnnotation!
    
    func configure(coordinate:CLLocationCoordinate2D) {
        theLatitude.text = "\(NSLocalizedString("Latitude", comment: "")): \(coordinate.latitude)"
        theLongitude.text = "\(NSLocalizedString("Longitude", comment: "")): \(coordinate.longitude)"
        theMarker.initForTable()
    }
}
