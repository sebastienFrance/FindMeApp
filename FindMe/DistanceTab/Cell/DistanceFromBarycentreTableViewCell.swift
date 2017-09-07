//
//  DistanceFromBarycentreTableViewCell.swift
//  FindMe
//
//  Created by Sébastien Brugalières on 30/08/2017.
//  Copyright © 2017 Sébastien Brugalières. All rights reserved.
//

import UIKit
import MapKit

class DistanceFromBarycentreTableViewCell: UITableViewCell {

    
    @IBOutlet weak var theAddress: UILabel!
    @IBOutlet weak var theLatitude: UILabel!
    @IBOutlet weak var theLongitude: UILabel!
    @IBOutlet weak var theDistance: UILabel!
    @IBOutlet weak var theMarker: EdgePinViewAnnotation!
 
    func configure(edgePin:EdgePin, center:Point) {
        theAddress.text = edgePin.address
        theLatitude.text = "\(NSLocalizedString("Latitude", comment: "")): \(edgePin.coordinate.latitude)"
        theLongitude.text = "\(NSLocalizedString("Longitude", comment: "")): \(edgePin.coordinate.longitude)"
        let distance = center.location.distance(from: CLLocation(latitude: edgePin.coordinate.latitude, longitude: edgePin.coordinate.longitude))
        let distanceFormatter = MKDistanceFormatter()
        distanceFormatter.units = .default
        distanceFormatter.unitStyle = .abbreviated
        theDistance.text = distanceFormatter.string(fromDistance: distance)
        
    }
}
