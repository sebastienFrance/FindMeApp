//
//  EdgePin.swift
//  FindMe
//
//  Created by Sébastien Brugalières on 23/08/2017.
//  Copyright © 2017 Sébastien Brugalières. All rights reserved.
//

import UIKit
import MapKit
import Contacts

class EdgePin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
 
    var placemark:CLPlacemark? = nil
    var distance = 100.0 // 100km is the default value
    var address:String {
        return getAddress()
    }
    
    let index:Int
    
    var renderingColor:UIColor
    var title:String? {
        return getAddress()
    }
    var subtitle: String? {
        return "Lat:\(coordinate.latitude) / Long: \(coordinate.longitude)"
    }

    init(edgeCoordinate:CLLocationCoordinate2D, color:UIColor, index initialIndex:Int) {
        coordinate = edgeCoordinate
        renderingColor = color
        index = initialIndex
    }
    
    var circle:MKCircle {
        return EdgeCircle.edgeCircleAtCenter(center: coordinate, radius: distance * 1000, color:renderingColor)
    }
    
    
    fileprivate func getAddress() -> String {
        if let thePlacemark = placemark {
            if let addressDictionary = thePlacemark.postalAddress {
                return CNPostalAddressFormatter.string(from: addressDictionary, style:.mailingAddress)
            } else {
                return NSLocalizedString("No_Address", comment: "")
            }
        } else {
            return "Lat: \(coordinate.latitude) Long: \(coordinate.longitude)"
        }
    }
}
