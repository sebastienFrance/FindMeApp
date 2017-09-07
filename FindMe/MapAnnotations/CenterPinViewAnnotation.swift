//
//  CenterPinViewAnnotation.swift
//  FindMe
//
//  Created by Sébastien Brugalières on 02/09/2017.
//  Copyright © 2017 Sébastien Brugalières. All rights reserved.
//

import UIKit
import MapKit

class CenterPinViewAnnotation: MKMarkerAnnotationView {

    override var annotation: MKAnnotation? {
        willSet {
            if let _ = newValue as? CenterPin {
                animatesWhenAdded = true
                glyphTintColor = UIColor.white
                glyphImage = #imageLiteral(resourceName: "Star Filled-40")
                markerTintColor = UIColor.green
                isDraggable = false
                canShowCallout = true
                displayPriority = .required
            }
        }
    }

    func initForTable() {
        animatesWhenAdded = false
        isDraggable = false
        canShowCallout = false
        glyphTintColor = UIColor.white
        glyphImage = #imageLiteral(resourceName: "Star Filled-40")
        markerTintColor = UIColor.green
        displayPriority = .required
    }
}
