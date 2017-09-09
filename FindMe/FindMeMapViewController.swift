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
    

    private let renderingColors = [UIColor.blue, UIColor.red, UIColor.orange]
    
    // Add a new EdgePin when the user has done a long pressure on the Map
    // Max 3 EdgePin can be added
    // The Map is refreshed with the new content
    @IBAction func handleLongPressGesture(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .ended:
            // We have already the max number of EdgePin, so we inform the user
            if TriangulationDS.sharedInstance.edgePoints.count == 3 {
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
            
            // Create the new EdgePin and add it in the datasource
            let newEdgePin = EdgePin(edgeCoordinate: newSelectedCoordinates,
                                     color:renderingColors[TriangulationDS.sharedInstance.edgePoints.count],
                                     index:TriangulationDS.sharedInstance.edgePoints.count + 1)
            
            TriangulationDS.sharedInstance.append(point:newEdgePin)

            theMapView.addAnnotation(newEdgePin)
            theMapView.add(newEdgePin.circle)
            
            // Geocode the address and refresh the annotation on the map with the address
            let geoCoder = CLGeocoder()
            let location = CLLocation(latitude: newSelectedCoordinates.latitude, longitude: newSelectedCoordinates.longitude)
            geoCoder.reverseGeocodeLocation(location) { placemarks, error in
                if error == nil, let thePlacemarks = placemarks, thePlacemarks.count > 0 {
                    newEdgePin.placemark = thePlacemarks[0]
                    self.theMapView.removeAnnotation(newEdgePin)
                    self.theMapView.addAnnotation(newEdgePin)
                }
            }
            
            if TriangulationDS.sharedInstance.edgePoints.count == 3 {
                refreshMapContent()
            }
            
        default:
            break
        }
    }
    
    // refresh the whole content of the map
    func refreshMapContent(updateCenter:Bool = true) {
        
        // Remove all Overlays and Annotation from the Map
        theMapView.removeOverlays(theMapView.overlays)
        theMapView.removeAnnotations(theMapView.annotations)
        
        // Recompute the center (and then the triangle)
        if updateCenter {
            _ = TriangulationDS.sharedInstance.updateCenter()
        }
        
        // Create all overlays and annotation to be displayed
        var newOverlays = [MKOverlay]()
        var newAnnotations = [MKAnnotation]()
        
        for edgePoint in TriangulationDS.sharedInstance.edgePoints {
            newOverlays.append(edgePoint.circle)
            newAnnotations.append(edgePoint)
        }
        
        // Add the Center and a polyline from all edges
        if let center = TriangulationDS.sharedInstance.center {
            let centerPin = CenterPin(centerCoordinate:center.coordinate)
            newAnnotations.append(centerPin)
            
            
            for edgePoint in TriangulationDS.sharedInstance.edgePoints {
                let polyline = EdgeToCenterPolyline.edgeToCenter(edgePin: edgePoint,
                                                                 centerPin: centerPin)
                newOverlays.append(polyline)
            }
        }
    
        // Draw the triangle only if we have 3 points
        if TriangulationDS.sharedInstance.trianglePoints.count == 3 {
            var coordinatesTriangle = [CLLocationCoordinate2D]()
            for currentTrianglePoint in TriangulationDS.sharedInstance.trianglePoints {
                newAnnotations.append(TrianglePin(centerCoordinate:currentTrianglePoint.coordinate))
                coordinatesTriangle.append(currentTrianglePoint.coordinate)
            }
            newOverlays.append(MKPolygon(coordinates: coordinatesTriangle, count: 3))
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
    
    // Dequeue Map annotation
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
    
    // Renderer for the overlays (circle, polyline and polygon)
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
        } else if let polyline = overlay as? EdgeToCenterPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: polyline)
            polylineRenderer.strokeColor = polyline.edge.renderingColor
            polylineRenderer.lineDashPattern = [20,10]
            polylineRenderer.lineJoin = .round
            polylineRenderer.lineCap = .square
            return polylineRenderer
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
                    self.refreshMapContent()
                }
            } else if let newCenterPin = view.annotation as? CenterPin {
                
                // The centerPin has been moved:
                //  - Update the distance from the EdgePint
                //  - Update the center in the datasource
                //  - Reset triangle in the datasource
                //  - Refresh the map with the updated datasource
                for currentEdgePin in TriangulationDS.sharedInstance.edgePoints {
                    let edgeLocation = CLLocation(latitude: currentEdgePin.coordinate.latitude, longitude: currentEdgePin.coordinate.longitude)
                    currentEdgePin.distance = edgeLocation.distance(from: CLLocation(latitude: newCenterPin.coordinate.latitude,
                                                                                     longitude: newCenterPin.coordinate.longitude)) / 1000.0
                }
                let newCenter = Point(name: "Manual Center", coordinate: newCenterPin.coordinate)
                TriangulationDS.sharedInstance.center = newCenter
                TriangulationDS.sharedInstance.trianglePoints.removeAll()
                refreshMapContent(updateCenter: false)
            }
        default:
            NSLog("\(#function) something is happening")
        }
    }
}
