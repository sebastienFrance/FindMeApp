//
//  EdgeCircle.swift
//  FindMe
//
//  Created by Sébastien Brugalières on 26/08/2017.
//  Copyright © 2017 Sébastien Brugalières. All rights reserved.
//

import UIKit
import MapKit

class EdgeCircle: MKCircle {

    var renderingColor:UIColor!
    
    
    class func edgeCircleAtCenter(center:CLLocationCoordinate2D, radius:CLLocationDistance, color:UIColor) -> EdgeCircle {
        let circle = EdgeCircle(center:center, radius:radius)
        circle.renderingColor = color
        return circle
    }
}
