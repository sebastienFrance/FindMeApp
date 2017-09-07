//
//  DistanceTriangleTableViewCell.swift
//  FindMe
//
//  Created by Sébastien Brugalières on 05/09/2017.
//  Copyright © 2017 Sébastien Brugalières. All rights reserved.
//

import UIKit

class DistanceTriangleTableViewCell: UITableViewCell {

    @IBOutlet weak var theTriangleAnnotation: TrianglePinAnnotationView!
    @IBOutlet weak var theLatitude: UILabel!
    @IBOutlet weak var theLongitude: UILabel!

    func configure(point:Point) {
        theLatitude.text = "\(NSLocalizedString("Latitude", comment: "")): \(point.coordinate.latitude)"
        theLongitude.text = "\(NSLocalizedString("Longitude", comment: "")): \(point.coordinate.longitude)"
   }
    
    func configure(error:String) {
        theLatitude.text = "\(error)"
        theLongitude.text = ""
    }
}
