//
//  EdgePinViewAnnotation.swift
//  FindMe
//
//  Created by Sébastien Brugalières on 02/09/2017.
//  Copyright © 2017 Sébastien Brugalières. All rights reserved.
//

import UIKit
import MapKit

class EdgePinViewAnnotation: MKMarkerAnnotationView {

    override var annotation: MKAnnotation? {
        willSet {
            if let edgeAnnotation = newValue as? EdgePin {
                animatesWhenAdded = true
                isDraggable = true
                canShowCallout = true
                initRenderingProperties(pin: edgeAnnotation)
            }
        }
    }
    
    
    func initWith(edgePin:EdgePin) {
        animatesWhenAdded = false
        isDraggable = false
        canShowCallout = false
        initRenderingProperties(pin: edgePin)
    }
    
    func initRenderingProperties(pin edgePin:EdgePin) {
        glyphTintColor = UIColor.white
        glyphText = "\(edgePin.index)"
        markerTintColor = edgePin.renderingColor
    }

}
