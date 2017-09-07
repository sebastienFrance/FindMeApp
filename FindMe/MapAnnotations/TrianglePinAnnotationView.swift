//
//  TrianglePinAnnotationView.swift
//  FindMe
//
//  Created by Sébastien Brugalières on 02/09/2017.
//  Copyright © 2017 Sébastien Brugalières. All rights reserved.
//

import MapKit

class TrianglePinAnnotationView: MKMarkerAnnotationView {

    override var annotation: MKAnnotation? {
        willSet {
            if let _ = newValue as? TrianglePin {
                animatesWhenAdded = true
                glyphTintColor = UIColor.white
                glyphImage = #imageLiteral(resourceName: "Triangle Filled-40")
                markerTintColor = UIColor.orange
                isDraggable = false
                canShowCallout = true
            }
        }
    }

    func initForTable() {
        glyphTintColor = UIColor.white
        glyphImage = #imageLiteral(resourceName: "Triangle Filled-40")
        markerTintColor = UIColor.orange
        
        animatesWhenAdded = false
        isDraggable = false
        canShowCallout = false
    }
}
