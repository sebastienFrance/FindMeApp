//
//  TrianglePin.swift
//  FindMe
//
//  Created by Sébastien Brugalières on 28/08/2017.
//  Copyright © 2017 Sébastien Brugalières. All rights reserved.
//

import UIKit
import MapKit

class TrianglePin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D

    var title:String? {
        return NSLocalizedString("Triangle", comment: "")
    }
    var subtitle: String? {
        return "Lat:\(coordinate.latitude) / Long: \(coordinate.longitude)"
    }

    init(centerCoordinate:CLLocationCoordinate2D) {
        coordinate = centerCoordinate
    }
    
}
