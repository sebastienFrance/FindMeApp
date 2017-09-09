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
    
    func distanceAngle(p:Point) -> Double {
        return distance(p:p) / Point.R
    }
    
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
        if coslam == 0.0 || cla < 1E-7 {
            // note : cla<1E-10 <==> 0.1 mm !!!, cla=1E-7 <=> 0.63m
            // cla==0.0 <=> this==Pole Nord/ Pole Sud
            // coslam==0 <=> M est au Pole Nord / Pole Sud
            if coslam == 0.0 {
                if sinlam > 0.0 {
                    return Point(name:"North Pole", coordinate: CLLocationCoordinate2D(latitude: 90.0, longitude: 0.0))
                } else {
                    return Point(name:"South Pole", coordinate: CLLocationCoordinate2D(latitude: -90.0, longitude: 0.0))
                }
            } else {
                // cla==0 <=>  this==north or south pole
                //simply take longitude=az and latitude=90-alpha
                
                if sla > 0.0 {
                    // this==north pole
                    return  Point(name:"->dist=\(dist),az=\(az)", coordinate: CLLocationCoordinate2D(latitude: 90.0 - alpha / Point.coef, longitude: az))
                } else {
                    // this == south pole
                    return  Point(name:"->dist=\(dist),az=\(az)", coordinate: CLLocationCoordinate2D(latitude: -90.0 + alpha / Point.coef, longitude: -az))
                }
            }
        } else {
            
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
    }
    
    func  toString() -> String {
        return "Point[\(name_)=(\(lat_),\(lo_))"
    }
    
    func getAzimuth(p2:Point) -> Double {
        
        let cosbeta = sla * p2.sla + cla * p2.cla * cos(lor_ - p2.lor_)
        let sinbeta = (1.0-cosbeta*cosbeta).squareRoot()
        if sinbeta == 0.0 {
            return 0.0
        } else {
            let sinaz = p2.cla * sin(lor_ - p2.lor_) / sinbeta
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
        if dist == 0.0 {
            return ret
        }
        if dist > dist1 + dist2 {
            NSLog("### WARNING ### il n'y a pas de point a distance d1=\(dist1) de \(p1.name_) et d2=\(dist2) de \(p2.name_), car la distance de p1 a p2 =\(dist) est superieure a la d1+d2=\(dist1+dist2)")
            // dans ce cas on fait comme si d1+d2==dist(p1,p2) et on prend le point tangent aux deux cercles
            // (au milieu des points les plus proches des deux cercles)
            let d = dist1 + (dist - dist1 - dist2) / 2.0
            let pp = Point.barycentre(p1:p1 ,p2:p2,weigth: d/dist);
            //System.out.println("pp="+pp);
            ret.append(pp);
            // add again the same point :
            ret.append(pp);
            return ret;
            
        }
        if dist < abs(dist2-dist1) {
            NSLog("### WARNING ### il n'y a pas de point a distance d1=\(dist1) de \(p1.name_) et d2=\(dist2) de \(p2.name_), car la distance de p1 a p2 =\(dist) est inferieur a |d1-d2|=\(abs(dist1-dist2))")
            return ret
            
            if dist1 >= dist2 {
                let deltadist = (dist1 - dist - dist2) / 2.0
                let d = dist1 - deltadist
                let pp = Point.barycentre(p1:p1,p2:p2,weigth:d/dist)  // here d/dist>1.0
                
                /*Point qq=Point.barycentre(p2,p1,(-dist2-deltadist)/dist); // here d<0
                 System.out.println("dist1>dist2 : qq="+qq);
                 Point ss=Point.barycentre(p1,p2,(dist+dist2+deltadist)/dist);
                 System.out.println("dist1>dist2 : ss="+ss);*/
                ret.append(pp);
                // add again the same point :
                ret.append(pp);
                return ret;
            } else {
                
                let d = dist2 - (dist2 - dist - dist1) / 2.0
                let pp=Point.barycentre(p1:p2,p2:p1,weigth:d/dist)  // here d/dist >1.0
                //System.out.println("dist1<dist2 : pp="+pp);
                ret.append(pp);
                // add again the same point :
                ret.append(pp);
                return ret;
            }
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
    
    static func normalizePoint(lat:Double, lon:Double) -> Point {
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        return Point(name:"Point to normalize:(\(lat),\(lon))", coordinate:coord)
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

