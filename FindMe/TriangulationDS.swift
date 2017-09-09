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


class TriangulationDS {
    
    class var sharedInstance: TriangulationDS {
        struct Singleton {
            static let instance = TriangulationDS()
        }
        return Singleton.instance
    }

    
    // List of Points set by the user on the Map to look for the triangulation
    private(set) var edgePoints = [EdgePin]()
    
    // Center point computed by the triangulation
    var center:Point? = nil
    
    // Triangle computed based on the distance from the edgePoints
    // This table can be empty
    var trianglePoints = [Point]()
    
    
    func append(point:EdgePin) {
        edgePoints.append(point)
    }
    
    func reset() {
        edgePoints.removeAll()
        center = nil
        trianglePoints.removeAll()
    }
    
    
    func updateCenter() -> Point? {
        trianglePoints = [Point]()
        center = nil
        
        if edgePoints.count != 3 {
            return nil
        }
        
        
        var pmin, qmin, rmin:Point?
        (center, pmin, qmin, rmin)  = Point.pointAt(p1:edgePoints[0].point,
                                                    dist1:edgePoints[0].distanceInMeter,
                                                    p2:edgePoints[1].point,
                                                    dist2:edgePoints[1].distanceInMeter,
                                                    p3:edgePoints[2].point,
                                                    dist3:edgePoints[2].distanceInMeter)
        
        if center != nil {
            if pmin != nil {
                trianglePoints.append(pmin!)
            }
            
            if qmin != nil {
                trianglePoints.append(qmin!)
            }
            
            if rmin != nil {
                trianglePoints.append(rmin!)
            }
        }
        
        return center
    }
}
