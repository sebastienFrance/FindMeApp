//
//  Point.swift
//  FindMe
//
//  Created by Sébastien Brugalières on 25/08/2017.
//  Copyright © 2017 Sébastien Brugalières. All rights reserved.
//

import Foundation
import MapKit

class Point {
    var lat_ = 0.0 // en degres
    var lo_ = 0.0 // en degres
    var lar_ = 0.0 // en radians
    var lor_ = 0.0 // en radians
    var cla = 0.0 // cos(la)
    var sla = 0.0 // sin(la)
    var clo = 0.0 // cos(lo)
    var slo = 0.0 // sin(lo)
    var name_ = ""
    
    var coordinate:CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(lat_, lo_)
    }
    
    var location:CLLocation {
        return CLLocation(latitude:lat_, longitude:lo_)
    }
    
    static let coef = Double.pi/180.0 // degrees to radians
    static let R = 6372797.6 // in km
    // two points are considered as same if their distnace in radian is less than the following value :
    static let MIN_DISTANCE_ALLOWED = 1000.0/R // <==> less than 1km
 
    // lat, lo given in degrees
    init(name:String, coordinate:CLLocationCoordinate2D) {
        lo_ = coordinate.longitude
        lat_ = coordinate.latitude
        name_ = name
        //normalize()
        initVal()
    }
    
//    func normalize() {
//        var lo = lo_
//        var la = lat_ - (Double)(180 * (Int)(lat_/180.0))
//        if la > 90.0 {
//            la = 180.0 - la
//            lo = lo + 180.0
//        }
//
//        if la < -90.0 {
//            la = -180.0 - la
//            lo = lo + 180.0
//        }
//
//        lo = Point.normalizeLongitude(lo:lo)
//        lat_ = la
//        lo_ = lo
//        initVal()
//    }
    func initVal() {
        lor_ = lo_ * Point.coef
        lar_ = lat_ * Point.coef
        cla = cos(lar_)
        sla = sin(lar_)
        clo = cos(lor_)
        slo = sin(lor_)
    }
    
    func distance(p:Point) -> Double {
        return location.distance(from: p.location)
    }

    
//    func distance(p:Point) -> Double {
//        // cos(d)=sin(la1)sin(la2)+cos(la1)cos(la2)cos(lo2-lo1);
//        let cosd = sla * p.sla + cla * p.cla * cos(lor_ - p.lor_)
//        let dist = Point.R * acos(cosd)
//        return dist;
//    }
    
    func distanceAngle(p:Point) -> Double {
        return distance(p:p) / Point.R
    }
//    func distanceAngle(p:Point) -> Double {
//        // return the distance between the two points as an angle in radian
//        let cosd = sla * p.sla + cla * p.cla * cos(lor_ - p.lor_)
//        let dist = acos(cosd)
//        return dist
//    }
    
    func opposite() -> Point {
        let pp = Point.normalizePoint( lat:-lat_, lon:lo_ + 180.0)
        pp.name_="Opposite[\(self.name_)]"
        return pp;
    }
    
    // az given in degrees, dist in km
    // az is the azimuth from Nord=0, south=180, west=90, east=270 or -90
    func pointAtAz(dist:Double, az:Double) -> Point {
        let alpha = dist / Point.R
        let azimuth = az * Point.coef  // azimuth in radians
        //System.out.println("dist="+dist+" ==> alpha="+alpha/coef);
        // compute the point M(lam,lom)
        // cos(lam)/sin(az)=sin(alpha)/sin(lo-lom)
        // cos(lo-lom)=(cos(alpha)-sin(lam)sin(la))/(cos(lam)cos(la));
        // sin(lam) = cos(alpha)*sin(la)+cos(la)sin(alpha)*cos(az)
        let sinlam = cos(alpha) * sla + cla * sin(alpha) * cos(azimuth)
        //System.out.println(name_+" + az="+az+" => sinlam="+sinlam+" alpha="+alpha/coef+" latM="+Math.asin(sinlam)/coef);
        let coslam = (1.0-sinlam*sinlam).squareRoot()
        
        let cosdeltalon = (cos(alpha) - sinlam * sla) / (coslam*cla)
        let sindeltalon = sin(alpha) * sin(azimuth) / coslam
        var deltalon = asin(sindeltalon)
        if cosdeltalon < 0 {
            deltalon = Double.pi - deltalon
        }
        //System.out.println("sindeltalon="+sindeltalon+" ==>deltalon="+deltalon/coef);
        let lam = asin(sinlam) / Point.coef // in degrees
        let lom = lo_ - deltalon / Point.coef
        
        //System.out.println("==> la="+lam+" lo="+lom);
        let coord = CLLocationCoordinate2D(latitude: lam, longitude: lom)
        
        return Point(name:"\(self.toString())->dist=\(dist),az=\(az)", coordinate:coord)

    }
    
    func  toString() -> String {
        return "Point[\(name_)=(\(lat_),\(lo_))"
    }
    
    func getAzimuth(p2:Point) -> Double {
        // cos(beta)=sin(p1.la)*sin(p2.la)+cos(p1.la)*cos(p2.la)*cos(p1.lo-p2.lo)
        // sin(az)/cos(p2.lat)=sin(p2.lo-p1.lo)/sin(beta)
        
        let cosbeta = sla * p2.sla + cla * p2.cla * cos(lor_ - p2.lor_)
        let sinbeta = (1.0-cosbeta*cosbeta).squareRoot()
        let sinaz = p2.cla * sin(lor_-p2.lor_) / sinbeta
        var az = asin(sinaz); // here az is -PI/2..PI/2
        //System.out.println("sinaz="+sinaz+" => az="+az/coef);
        // sin(P2.la)=cosbeta*sin(la)+sinbeta*cos(la)*cos(az)
        let cosaz = (p2.sla - cosbeta*sla) / (sinbeta*cla)  // az is 0..PI
        if cosaz < 0 {
            az = Double.pi - az
        }
        //System.out.println("cosaz="+cosaz +" => az="+az/coef);
        return az / Point.coef;
    }

    // ========== Utils
    
    static func distance(p1:Point, p2:Point) -> Double {
        return p1.distance(p: p2)
    }
    
    static func pointAt(p1:Point, dist1:Double, p2:Point, dist2:Double) -> Array<Point> {
        // return the two points which are at distance dist1 from p1 and dist2 from p2
        
        // NOTE : there is no solution if dist1+dist2< distance(p1,p2);
        var ret = Array<Point>()
        let dist = Point.distance(p1:p1,p2:p2)
        
        if dist > dist1 + dist2 {
            NSLog("### WARNING ### il n'y a pas de point a distance d1=\(dist1) de \(p1.name_) et d2=\(dist2) de \(p2.name_), car la distance de p1 a p2 =\(dist) est superieure a la d1+d2=\(dist1+dist2)")
            return ret
        }
        if dist < abs(dist2-dist1) {
            NSLog("### WARNING ### il n'y a pas de point a distance d1=\(dist1) de \(p1.name_) et d2=\(dist2) de \(p2.name_), car la distance de p1 a p2 =\(dist) est inferieur a |d1-d2|=\(abs(dist1-dist2))")
            return ret
        }
        let alpha1 = dist1/Point.R
        let alpha2 = dist2/Point.R
        // NOTE : alpha1 et alpha2 doivent etre <= PI
        
        let ca1 = cos(alpha1)
        let ca2 = cos(alpha2)
        let sa2 = sin(alpha2)
        //double sa1=Math.sin(alpha1);
        let cosbeta = p1.sla * p2.sla + p1.cla * p2.cla * cos(p1.lor_-p2.lor_)
        //System.out.println("cosbeta="+cosbeta+ " => beta="+Math.acos(cosbeta)/coef);
        let sinbeta = (1-cosbeta*cosbeta).squareRoot() // ok always >=0
        if sinbeta == 0.0 {
            NSLog("### ERROR ### NOT YET IMPLEMENTED : sinbeta==0 !!")
        } else {
            let cosdelta = (ca1-cosbeta*ca2)/(sinbeta*sa2)
            let delta = acos(cosdelta)/coef
            // delta is always good : 0..PI but -delta is also a solution !
            //System.out.println("cosdelta="+cosdelta+" delta="+delta);
            
            let az1 = p2.getAzimuth(p2:p1);
            //System.out.println("az1="+az1);
            let M = p2.pointAtAz(dist:dist2, az:(az1-delta))
            let M2 = p2.pointAtAz(dist:dist2, az:(az1+delta))
            ret.append(M)
            ret.append(M2)
        }
        NSLog("PointAt : ret=\(ret)");
        return ret;
    }
    
 
    // ==== Mandatory static
//    static func normalizeLongitude(lo:Double) -> Double {
//        var normLongitude = lo
//        while  normLongitude < 0.0 {
//            normLongitude = normLongitude + 360.0
//        }
//        normLongitude = normLongitude - (Double)(360 * (Int)(normLongitude / 360.0))
//        if normLongitude > 180.0 {
//            normLongitude = normLongitude - 360.0
//        }
//        return normLongitude
//    }

    static func normalizePoint(lat:Double, lon:Double) -> Point {
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        return Point(name:"Point to normalize:(\(lat),\(lon))", coordinate:coord)
        
//        // return always a latitude from -90 to 90 :
//        var lo = lon
//        var la = lat - (Double)(180 * (Int)(lat/180.0))
//        if la > 90.0 {
//            la = 180.0 - la
//            lo = lo + 180.0
//        }
//
//        if la < -90.0 {
//            la = -180.0 - la
//            lo = lo + 180.0
//        }
//        lo = normalizeLongitude(lo:lo)
//
//        let coord = CLLocationCoordinate2D(latitude: la, longitude: lo)
//
//        return Point(name:"Point to normalize:(\(lat),\(lon))", coordinate:coord)
    }
    
    static func pointAt(p1:Point, dist1:Double, p2:Point, dist2:Double, p3:Point, dist3:Double) -> (center:Point?, pmin:Point?, qmin:Point?, rmin:Point?) {
        
        
        // list1 is the list of two points whose distances to p1 and p2 are respectively dist1 and dist2
        let list1=Point.pointAt(p1:p1,dist1:dist1,p2:p2,dist2:dist2)
        let list2=Point.pointAt(p1:p1,dist1:dist1,p2:p3,dist2:dist3)
        let list3=Point.pointAt(p1:p2,dist1:dist2,p2:p3,dist2:dist3)
        
        if list1.isEmpty || list2.isEmpty || list3.isEmpty {
            return (nil, nil, nil, nil)
        }
        // normalement, les trois listes contiennent un point commun qui est le point cherche
        // aux erreurs pres, le point cherche est tout pres d'un des deux points de chaque liste
        var pmin:Point?
        var qmin:Point?
        var min = Double.greatestFiniteMagnitude
        for pp in list1 {
            for qq in list2 {
                let dist=Point.distance(p1:pp,p2:qq)
                if dist < min {
                    min = dist
                    pmin = pp
                    qmin = qq
                }
            }
        }
        
        var rmin:Point? 
        min = Double.greatestFiniteMagnitude
        for pp in list3 {
            let dist=Point.distance(p1:pp,p2:pmin!)
            if  dist < min {
                rmin = pp
                min = dist
            }
        }
        NSLog("pmin=\(pmin!)")
        NSLog("qmin=\(qmin!)")
        NSLog("rmin=\(rmin!)")
        
        // Warning: Maybe we should not use optional here for Points
        let pp = Point.barycentre(p1:pmin!, p2:qmin!, p3:rmin!)
        return (pp,pmin,qmin,rmin)

    }
    
    static func isOppositePoints(p1:Point, p2:Point) -> Bool {
        let n1 = Point.normalizePoint(lat: p1.lat_, lon: p1.lo_)
        let n2 = Point.normalizePoint(lat: p2.lat_, lon: p2.lo_)
        let op1 = Point.normalizePoint(lat: -n1.lat_, lon: n1.lo_+180.0)
        return n2.distanceAngle(p:op1) < MIN_DISTANCE_ALLOWED

    }
    
    static func milieu(p1:Point, p2:Point) -> Point {
        let pp = Point.barycentre(p1:p1, p2:p2, weigth:0.5)
        pp.name_ = "milieu de :{\(p1.name_);\(p2.name_)}"
        return pp
    }
    
    static func barycentre(p1:Point, p2:Point, weigth:Double) -> Point {
        // taking mean of lat/lon is very bad and completely false !
        ///double blat=(p1.lat_+p2.lat_)/2.0;
        //double blon=(p1.lo_+p2.lo_)/2.0;
        let az=p1.getAzimuth(p2: p2)
        let dist=p1.distance(p: p2)
        let mi=p1.pointAtAz(dist:dist*weigth, az:az)
        mi.name_ = "bary de :{\(p1.name_)*\(weigth);\(p2.name_)*\((1.0-weigth))}"
        return mi
    }
    
    static func barycentre(p1:Point, p2:Point, p3:Point) -> Point {
        // TODO : check this method !
        // is it good : the mean of lat/long ???
        // non : ca ne marche pas pour (poleNord,poleSud2,Paris) : quand il y a deux point opposes, il ya une infinite
        // de grands cercles de longitudes differentes et donc le barycentre est possiblement partout sur la longitude moyenne
        /*double blat=(p1.lat_+p2.lat_+p3.lat_)/3.0;
         double blon=(p1.lo_+p2.lo_+p3.lo_)/3.0;
         double d1=p1.distance(p2);
         double d2=p1.distance(p3);
         double d3=p2.distance(p3);
         double dist=(d1>d2?d1:d2);
         dist=(dist>d3?dist:d3);
         Point z1=p1;
         Point z2=p2;
         Point z3=p3;
         while (dist>0.1) {
         Point m1=milieu(z1,z2);
         Point m2=milieu(z1,z3);
         Point m3=milieu(z2,z3);
         dist=maxdist(m1,m2,m3);
         z1=m1;
         z2=m2;
         z3=m3;
         }*/
        // another method :
        let m1 = Point.milieu(p1:p1,p2:p2)
        NSLog("m1=\(m1)")
        let bary = barycentre(p1:p3,p2:m1,weigth:2.0/3.0)
        //System.out.println("barycentre bad="+blat+","+blon+" good="+z1.lat_+","+z1.lo_+" z2="+z2.lat_+","+z2.lo_);
        NSLog("bary real=\(bary)")
        return bary;
        //return new Point("barycentre de :{"+p1.name_+";"+p2.name_+";"+p3.name_+"}",z1.lat_,z1.lo_);
    }
    
    // max dist in km
    static func maxdist(p1:Point, p2:Point, p3:Point) -> Double {
        let d1 = p1.distance(p:p2)
        let d2 = p1.distance(p:p3)
        let d3 = p2.distance(p:p3)
        var dist = (d1 > d2 ? d1 : d2)
        dist = (dist > d3 ? dist: d3)
        return dist
    }
    
    static func getPlusPres(p1:Point, p2:Point, p3:Point) -> Point{
        if p3.distance(p:p1) < p3.distance(p:p2) {
            return p1
        } else {
            return p2
        }
    }
}
