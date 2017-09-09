//
//  FindMeTests.swift
//  FindMeTests
//
//  Created by Sébastien Brugalières on 23/08/2017.
//  Copyright © 2017 Sébastien Brugalières. All rights reserved.
//

import XCTest
import MapKit
@testable import FindMe

class FindMeTests: XCTestCase {
    
    static let Paris = Point(name:"Paris", coordinate: CLLocationCoordinate2DMake(48.853, 2.35))
    static let  Moscou = Point(name:"Moscou", coordinate: CLLocationCoordinate2DMake(55.755826,37.6173))
    static let  Rio = Point(name:"Rio", coordinate: CLLocationCoordinate2DMake(-22.906847,-43.172896))
    static let NewYork = Point(name:"NewYork", coordinate: CLLocationCoordinate2DMake(40.712784,-74.005941))
    
    static let poleNord = Point(name:"PoleNord", coordinate: CLLocationCoordinate2DMake(90.0,0.0))
    static let poleNord2 = Point(name:"PoleNord", coordinate: CLLocationCoordinate2DMake(90.0,190.0))
    static let poleSud = Point(name:"PoleSud", coordinate: CLLocationCoordinate2DMake(-90.0,0.0))
    static let poleSud2 = Point(name:"PoleSud", coordinate: CLLocationCoordinate2DMake(-90.0,160.0))
    
    static let equat0 = Point(name:"equateur0", coordinate: CLLocationCoordinate2DMake(0.0,0.0))
    static let equat1 = Point(name:"equateur55", coordinate: CLLocationCoordinate2DMake(0.0,55.0))
    static let equat180 = Point(name:"equateur180", coordinate: CLLocationCoordinate2DMake(0.0,180.0))

    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMain() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        NSLog("\n--------------------------------")
        let dist = FindMeTests.Paris.distance(p:FindMeTests.Moscou)
        NSLog("distance :paris-moscou=\(dist/1000) km")
        // result : distance :paris-moscou=2486.5941557741317
        
        
        NSLog("\n--------------------------------")
        let d1 = FindMeTests.Paris.distance(p:FindMeTests.NewYork)
        NSLog("distance paris-NY :\(d1/1000)km")
        let d2 = FindMeTests.Rio.distance(p:FindMeTests.NewYork)
        NSLog("distance rio-NY :\(d2/1000)km")
        let d3 = FindMeTests.Moscou.distance(p:FindMeTests.NewYork)
        NSLog("distance moscou-NY :\(d3/1000)km")
        NSLog("\n--------------------------------")
        let points = Point.pointAt(p1:FindMeTests.Paris, dist1:d1, p2:FindMeTests.Rio, dist2:d2, p3:FindMeTests.Moscou, dist3:d3)
        XCTAssertNotNil(points.center)
        let result = points.center!.distance(p:FindMeTests.NewYork)
        NSLog("le point qui est a :\(d1/1000)km de Paris, \(d2/1000)km de Rio, \(d3/1000)km de Moscou est :\(points.center!.toString()) qui est cense etre New-York :\(FindMeTests.NewYork.toString())")
        NSLog("distance entre le point calcule et le vrai point (NY) :\(result / 1000)km")

    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
