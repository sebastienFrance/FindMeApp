//
//  EdgeToCenterPolyline.swift
//  FindMe
//
//  Created by Sébastien Brugalières on 09/09/2017.
//  Copyright © 2017 Sébastien Brugalières. All rights reserved.
//

import UIKit
import MapKit

class EdgeToCenterPolyline: MKPolyline {

    var edge:EdgePin!
    var center: CenterPin!
    
    
    class func edgeToCenter(edgePin:EdgePin, centerPin:CenterPin) -> EdgeToCenterPolyline {
        
        let pt = [ MKMapPointForCoordinate(edgePin.coordinate), MKMapPointForCoordinate(centerPin.coordinate)]
        let edgeToCenter = EdgeToCenterPolyline(points: pt, count: 2)
        
        edgeToCenter.edge = edgePin
        edgeToCenter.center = centerPin
        return edgeToCenter
    }

    
}
