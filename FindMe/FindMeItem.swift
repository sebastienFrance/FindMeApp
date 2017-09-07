//
//  FindMeItem.swift
//  FindMe
//
//  Created by Sébastien Brugalières on 26/08/2017.
//  Copyright © 2017 Sébastien Brugalières. All rights reserved.
//

import Foundation
import MapKit
import Contacts


class FindMeItem {
    
    class var sharedInstance: FindMeItem {
        struct Singleton {
            static let instance = FindMeItem()
        }
        return Singleton.instance
    }

    
    private(set) var edgePoints = [EdgePin]()
    
    var center:Point? = nil
    var pmin:Point? = nil
    var qmin: Point? = nil
    var rmin: Point? = nil
    
    var centerAddress:String {
        if let theCenter = center {
            return "\(theCenter.lat_) / \(theCenter.lo_)"
        } else {
            return NSLocalizedString("Center_Not_Exist", comment: "")
        }
    }
    
    func append(point:EdgePin) {
        edgePoints.append(point)
    }
    
    func reset() {
        edgePoints.removeAll()
        center = nil
        pmin = nil
        qmin = nil
        rmin = nil
    }
    
    
     func trianglePointFor(index:Int) -> Point? {
        if index == 0 {
            return pmin
        } else if index == 1 {
            return rmin
        } else {
            return qmin
        }
    }

    
    func updateCenter(sourceViewController:UIViewController) -> Point? {
        if edgePoints.count != 3 {
            return nil
        }
        
        let point1 = Point(name: "Point1", coordinate: edgePoints[0].coordinate)
        let point2 = Point(name: "Point2", coordinate: edgePoints[1].coordinate)
        let point3 = Point(name: "Point3", coordinate: edgePoints[2].coordinate)
        
        let d1 = edgePoints[0].distance
        NSLog("distance 0 :\(d1)")
        let d2 = edgePoints[1].distance
        NSLog("distance 1 :\(d2)")
        let d3 = edgePoints[2].distance
        NSLog("distance 2 :\(d3)")
        NSLog("\n--------------------------------")
        
        (center, pmin, qmin, rmin)  = Point.pointAt(p1:point1, dist1:d1*1000, p2:point2, dist2:d2*1000, p3:point3, dist3:d3*1000)
        

        
        return center

    }
}
