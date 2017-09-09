//
//  ViewController.swift
//  FindMe
//
//  Created by Sébastien Brugalières on 23/08/2017.
//  Copyright © 2017 Sébastien Brugalières. All rights reserved.
//

import UIKit
import MapKit


class DistanceConfigurationViewController: UIViewController {

    @IBOutlet weak var theTableView: UITableView! {
        didSet {
            if let tableview = theTableView {
                tableview.delegate = self
                tableview.dataSource = self
                tableview.estimatedRowHeight = 94
                tableview.rowHeight = UITableViewAutomaticDimension
                tableview.tableFooterView = UIView(frame: CGRect.zero) // remove separator for empty lines
            }
        }
    }
    
    // Active TextField when the Keyboard is displayed
    var activeTextField: UITextField?
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerKeyboardNotifications()
        // Table content may have changed when the map was display => Must refresh the tableView
        theTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        deRegisterKeyboardNotifications()
    }
    
    //MARK: - Keyboard notification observer Methods
    fileprivate func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(DistanceConfigurationViewController.keyboardWillShow),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(DistanceConfigurationViewController.keyboardWillHide),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
    }
    
    fileprivate func deRegisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardDidHide, object: self.view.window)
    }
    
    
    /// Scroll the tableView when the Keyboard is displayed (when needed)
    ///
    /// - Parameter notification: notification when the keyboard is raised
    @objc func keyboardWillShow(notification: NSNotification) {
        
        // Extract the Keyboard size
        
        let info = notification.userInfo! as NSDictionary
        let value = info.value(forKey: UIKeyboardFrameBeginUserInfoKey) as! NSValue
        let keyboardSize = value.cgRectValue.size
        let valueHeight = info.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardForHeight = valueHeight.cgRectValue.size

        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardForHeight.height, 0.0)
        theTableView.contentInset = contentInsets
        theTableView.scrollIndicatorInsets = contentInsets
        
        // If active text field is hidden by keyboard, scroll it so it's visible
        // Your app might not need or want this behavior.
        var aRect = self.view.frame
        aRect.size.height -= keyboardSize.height
        if (!aRect.contains(activeTextField!.frame.origin)) {
            theTableView.scrollRectToVisible(activeTextField!.frame, animated:true)
        }
        
    }
    
    
    /// Reset the tableview scroll when the Keyboard is hidden
    ///
    /// - Parameter notification: notification when the keyboard is hidden
    @objc func keyboardWillHide(notification: NSNotification) {
        theTableView.contentInset = .zero
        theTableView.scrollIndicatorInsets = .zero
    }
    
    
    /// Reset the whole application when the user has pressed the reset button
    ///
    /// - Parameter sender: event
    @IBAction func resetButtonPressed(_ sender: UIBarButtonItem) {
        TriangulationDS.sharedInstance.reset()
        FindMeMapViewController.sharedInstance.refreshMapContent()
        theTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}



extension DistanceConfigurationViewController : UITextFieldDelegate {
 
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }

    
    /// Update the distance of the edgePin with the new value
    /// and refresh the Map with the new values.
    /// The Keyboard is removed from the screen
    ///
    /// - Parameter textField: <#textField description#>
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        TriangulationDS.sharedInstance.edgePoints[textField.tag].distance = Double(textField.text!)!
        
        FindMeMapViewController.sharedInstance.refreshMapContent()
        theTableView.reloadData()
        
        resignFirstResponder()
        activeTextField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension DistanceConfigurationViewController: UITableViewDelegate {
    
    
    /// Initialize the Marker displayed in the cell. MKMarkerAnnotationView cannot be
    /// initialized correctly in the tableview(cellForRowAt) else it doesn't display correctly
    ///
    /// - Parameters:
    ///   - tableView: the tableview
    ///   - cell: the cell
    ///   - indexPath: index of the cell to update
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case SectionId.edgePoints:
            if let theCell = cell as? DistanceConfigurationTableViewCell {
                theCell.theMarker.initWith(edgePin:TriangulationDS.sharedInstance.edgePoints[indexPath.row])
            }
        case SectionId.triangulationResult:
            if indexPath.row == 0 {
                if let theCell = cell as? CenterTableViewCell {
                    theCell.theMarker.initForTable()
                }
            } else {
                if let theCell = cell as? DistanceFromBarycentreTableViewCell {
                    theCell.theMarker.initWith(edgePin:TriangulationDS.sharedInstance.edgePoints[indexPath.row - 1])
                }
            }
        case SectionId.trianglePoints:
            if let theCell = cell as? DistanceTriangleTableViewCell {
                theCell.theTriangleAnnotation.initForTable()
            }
        default:
            break
        }
    }
}

extension DistanceConfigurationViewController: UITableViewDataSource {
    
    struct SectionId {
        static let edgePoints = 0
        static let triangulationResult = 1
        static let trianglePoints = 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if TriangulationDS.sharedInstance.trianglePoints.count > 0 {
            return 3
        } else if TriangulationDS.sharedInstance.center != nil {
                return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case SectionId.edgePoints:
            return NSLocalizedString("Section_SourcePoints", comment: "")
        case SectionId.triangulationResult:
            return NSLocalizedString("Section_TriangulationResult", comment: "")
        case SectionId.trianglePoints:
             return NSLocalizedString("Section_TriangleCoordinates", comment: "")
        default:
            return "Unknown section"
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SectionId.edgePoints:
            return TriangulationDS.sharedInstance.edgePoints.count
        case SectionId.triangulationResult:
            return 4
        case SectionId.trianglePoints:
            return TriangulationDS.sharedInstance.trianglePoints.count
        default:
            return 0
            
        }
    }
    
    struct CellId {
        static let DistanceConfigurationCellId = "DistanceConfigurationCellId"
        static let CenterCellId = "CenterCellId"
        static let DistanceFromBarycentreCellId = "DistanceFromBarycentreCellId"
        static let TriangleCellId = "TriangleCellId"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case SectionId.edgePoints:
            if let cell = theTableView.dequeueReusableCell(withIdentifier: CellId.DistanceConfigurationCellId, for: indexPath) as? DistanceConfigurationTableViewCell {
                cell.configure(edgePin:TriangulationDS.sharedInstance.edgePoints[indexPath.row], index:indexPath.row, textDelegate:self)
                return cell
            }
        case SectionId.triangulationResult:
            if indexPath.row == 0 {
                if let cell = theTableView.dequeueReusableCell(withIdentifier: CellId.CenterCellId, for:indexPath) as? CenterTableViewCell {
                    cell.configure(coordinate:TriangulationDS.sharedInstance.center!.coordinate)
                    return cell
                }
            } else {
                if let cell = theTableView.dequeueReusableCell(withIdentifier: CellId.DistanceFromBarycentreCellId, for: indexPath) as? DistanceFromBarycentreTableViewCell {
                    cell.configure(edgePin: TriangulationDS.sharedInstance.edgePoints[indexPath.row - 1], center: TriangulationDS.sharedInstance.center!)
                    return cell
                }
            }
        case SectionId.trianglePoints:
            if let cell = theTableView.dequeueReusableCell(withIdentifier: CellId.TriangleCellId, for: indexPath) as? DistanceTriangleTableViewCell {
                cell.configure(point:TriangulationDS.sharedInstance.trianglePoints[indexPath.row])
                return cell
            }
        default:
            break
        }
        
        return UITableViewCell()
    }
 }
