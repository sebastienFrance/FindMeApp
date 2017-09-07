//
//  DistanceConfigurationTableViewCell.swift
//  FindMe
//
//  Created by Sébastien Brugalières on 23/08/2017.
//  Copyright © 2017 Sébastien Brugalières. All rights reserved.
//

import UIKit
import MapKit

class DistanceConfigurationTableViewCell: UITableViewCell {

    @IBOutlet weak var theLabel: UILabel!
    @IBOutlet weak var theLatitude: UILabel!
    @IBOutlet weak var theLongitude: UILabel!
    @IBOutlet weak var theTextField: UITextField!
    @IBOutlet weak var theMarker: EdgePinViewAnnotation!
    
    func configure(edgePin:EdgePin, index:Int, textDelegate:UITextFieldDelegate) {
        theLabel.text = edgePin.address
        let coord = edgePin.coordinate
        theLatitude.text = "\(NSLocalizedString("Latitude", comment: "")): \(coord.latitude)"
        theLongitude.text = "\(NSLocalizedString("Longitude", comment: "")): \(coord.longitude)"
        theTextField.text = "\(edgePin.distance)"
        theTextField.delegate = textDelegate
        theTextField.tag = index
        
    }
}
