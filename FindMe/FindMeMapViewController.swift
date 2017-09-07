//
//  FindMeMapViewController.swift
//  FindMe
//
//  Created by Sébastien Brugalières on 23/08/2017.
//  Copyright © 2017 Sébastien Brugalières. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class FindMeMapViewController: UIViewController {
    
    static var sharedInstance:FindMeMapViewController!
    
    var findMe = FindMeItem.sharedInstance
    var centerPin: CenterPin? = nil
    
    @IBOutlet weak var theMapView: MKMapView! {
        didSet {
            theMapView.delegate = self
            theMapView.mapType = .hybridFlyover
            theMapView.showsUserLocation = true
            theMapView.showsScale = true
            theMapView.showsCompass = true
            theMapView.showsPointsOfInterest = true
            theMapView.showsBuildings = true
            
            theMapView.register(CenterPinViewAnnotation.self, forAnnotationViewWithReuseIdentifier: TriangulationAnnotation.centerPin)
            theMapView.register(TrianglePinAnnotationView.self, forAnnotationViewWithReuseIdentifier: TriangulationAnnotation.trianglePin)
            theMapView.register(EdgePinViewAnnotation.self, forAnnotationViewWithReuseIdentifier: TriangulationAnnotation.edgePin)
        }
    }
    
    override func viewDidLoad() {
        FindMeMapViewController.sharedInstance = self
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cleanupMap() {
        theMapView.removeAnnotations(theMapView.annotations)
        theMapView.removeOverlays(theMapView.overlays)
    }
    

    private let renderingColors = [UIColor.blue, UIColor.red, UIColor.darkGray]
    
    @IBAction func handleLongPressGesture(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .ended:
            if findMe.edgePoints.count == 3 {
                let alertController = UIAlertController(title: NSLocalizedString("Warning", comment: ""),
                                                        message: NSLocalizedString("Warning_Too_Many_EdgePin", comment: ""),
                                                        preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: NSLocalizedString("Close", comment: ""),
                                                        style: .cancel,
                                                        handler: nil))
                present(alertController, animated: true, completion: nil)
                return
            }
            
            let newSelectedCoordinates = theMapView.convert(sender.location(in: theMapView), toCoordinateFrom: theMapView)

            
            let newEdgePin = EdgePin(edgeCoordinate: newSelectedCoordinates, color:renderingColors[findMe.edgePoints.count], index:findMe.edgePoints.count + 1)
            findMe.append(point:newEdgePin)

            theMapView.addAnnotation(newEdgePin)
            theMapView.add(newEdgePin.circle)
            
            let geoCoder = CLGeocoder()
            let location = CLLocation(latitude: newSelectedCoordinates.latitude, longitude: newSelectedCoordinates.longitude)
            geoCoder.reverseGeocodeLocation(location) { placemarks, error in
                if error == nil, let thePlacemarks = placemarks, thePlacemarks.count > 0 {
                    newEdgePin.placemark = thePlacemarks[0]
                    self.updateMapDisplay()
                }
            }
            
            if findMe.edgePoints.count == 3 {
                updateMapDisplay()
            }
            
        default:
            break
        }
    }
    
    
    func updateMapDisplay() {
        
        theMapView.removeOverlays(theMapView.overlays)
        theMapView.removeAnnotations(theMapView.annotations)
        
        _ = findMe.updateCenter(sourceViewController: self)
        
        var newOverlays = [MKOverlay]()
        var newAnnotations = [MKAnnotation]()
        for edgePoint in findMe.edgePoints {
            newOverlays.append(edgePoint.circle)
            newAnnotations.append(edgePoint)
        }
        
        if let center = findMe.center {
            centerPin = CenterPin(centerCoordinate:center.coordinate)
            newAnnotations.append(centerPin!)
            
            let target = CLLocation(latitude: center.coordinate.latitude, longitude: center.coordinate.longitude)
            let source = CLLocation(latitude: theMapView.centerCoordinate.latitude, longitude:theMapView.centerCoordinate.longitude)
            let withAnimation = target.distance(from: source) <= 1000000 ? true : false
            theMapView.setCenter(center.coordinate, animated: withAnimation)
        }
        
        
        if let pmin = findMe.pmin, let qmin = findMe.qmin, let rmin = findMe.rmin {
            newAnnotations.append(TrianglePin(centerCoordinate:pmin.coordinate))
            newAnnotations.append(TrianglePin(centerCoordinate:qmin.coordinate))
            newAnnotations.append(TrianglePin(centerCoordinate:rmin.coordinate))

            // WARNING: Check how unsafeMutablePointer are working
            let pt = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: 3)
            let coordinatesTriangle = [pmin.coordinate, qmin.coordinate, rmin.coordinate]
            for i in 0..<3 {
                pt[i] = coordinatesTriangle[i]
            }
            
            newOverlays.append(MKPolygon(coordinates: pt, count: 3))
            pt.deallocate(capacity: 3)
        }

        theMapView.addAnnotations(newAnnotations)
        theMapView.addOverlays(newOverlays)
    }

}


extension FindMeMapViewController: MKMapViewDelegate {
    
    private struct TriangulationAnnotation {
        static let edgePin = "EdgePin"
        static let centerPin = "CenterPin"
        static let trianglePin = "TrianglePin"
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

         if let edgeAnnotation = annotation as? EdgePin {
            return mapView.dequeueReusableAnnotationView(withIdentifier: TriangulationAnnotation.edgePin, for: edgeAnnotation) as! EdgePinViewAnnotation
        } else if let centerAnnotation = annotation as? CenterPin {
            return mapView.dequeueReusableAnnotationView(withIdentifier: TriangulationAnnotation.centerPin, for: centerAnnotation) as! MKMarkerAnnotationView
        } else if let triangleAnnotation = annotation as? TrianglePin {
            return mapView.dequeueReusableAnnotationView(withIdentifier: TriangulationAnnotation.trianglePin, for: triangleAnnotation) as! MKMarkerAnnotationView
        }
        return nil
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let circleOverlay = overlay as? EdgeCircle {
            let circleRenderer  = MKCircleRenderer(circle: circleOverlay)
            circleRenderer.strokeColor = circleOverlay.renderingColor
            return circleRenderer
        } else if let polygon = overlay as? MKPolygon {
            let polygonRenderer = MKPolygonRenderer(overlay: polygon)
            polygonRenderer.fillColor = UIColor.black.withAlphaComponent(0.3)
            polygonRenderer.strokeColor = UIColor.black
            return polygonRenderer
        } else {
            return MKOverlayRenderer()
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        switch newState {
        case .ending:
            if let newEdgePin = view.annotation as? EdgePin {
                let geoCoder = CLGeocoder()
                let location = CLLocation(latitude: newEdgePin.coordinate.latitude, longitude: newEdgePin.coordinate.longitude)
                geoCoder.reverseGeocodeLocation(location) { placemarks, error in
                    if error == nil, let thePlacemarks = placemarks, thePlacemarks.count > 0 {
                        newEdgePin.placemark = thePlacemarks[0]
                    }
                    // Update the Map even when the GeoCoder has failed because we need to redraw the circle and others
                    // Map infos with the new GeoLocation
                    self.updateMapDisplay()
                }
            }
        default:
            NSLog("\(#function) something is happening")
        }
    }
}
