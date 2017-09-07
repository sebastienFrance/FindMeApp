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
    
    var activeTextField: UITextField?
    
    var findMe:FindMeItem = FindMeItem.sharedInstance

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerKeyboardNotifications()
        theTableView.reloadData() // Table content may have changed when the map was display => Must refresh the tableVie
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        let info = notification.userInfo! as NSDictionary
        let value = info.value(forKey: UIKeyboardFrameBeginUserInfoKey) as! NSValue
        let keyboardSize = value.cgRectValue.size
        let value2 = info.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardSize2 = value2.cgRectValue.size
        NSLog("\(keyboardSize) \(keyboardSize2)")
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize2.height, 0.0)
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
    
    @objc func keyboardWillHide(notification: NSNotification) {
        theTableView.contentInset = .zero
        theTableView.scrollIndicatorInsets = .zero
    }
    
    @IBAction func resetButtonPressed(_ sender: UIBarButtonItem) {
        findMe.reset()
        FindMeMapViewController.sharedInstance.updateMapDisplay()
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

    
    func textFieldDidEndEditing(_ textField: UITextField) {
        NSLog("\(#function) : \(textField.text!) for \(textField.tag)")
        
        findMe.edgePoints[textField.tag].distance = Double(textField.text!)!
        
        FindMeMapViewController.sharedInstance.updateMapDisplay()
        theTableView.reloadData()
        
        resignFirstResponder()
        
        activeTextField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        NSLog("\(#function) : \(textField.text!) for \(textField.tag)")
        textField.resignFirstResponder()
        return true
    }
}

extension DistanceConfigurationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case SectionId.edgePoints:
            if let theCell = cell as? DistanceConfigurationTableViewCell {
                theCell.theMarker.initWith(edgePin:findMe.edgePoints[indexPath.row])
            }
        case SectionId.triangulationResult:
            if indexPath.row == 0 {
                if let theCell = cell as? CenterTableViewCell {
                    theCell.theMarker.initForTable()
                }
            } else {
                if let theCell = cell as? DistanceFromBarycentreTableViewCell {
                    theCell.theMarker.initWith(edgePin:findMe.edgePoints[indexPath.row - 1])
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
       return findMe.center != nil ? 3 : 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case SectionId.edgePoints:
            return "Source Points"
        case SectionId.triangulationResult:
            return "Triangulation Result"
        case SectionId.trianglePoints:
             return "Triangle Points"
        default:
            return "Unknown section"
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SectionId.edgePoints:
            return findMe.edgePoints.count
        case SectionId.triangulationResult:
            return 4
        case SectionId.trianglePoints:
            return 3
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
                cell.configure(edgePin:findMe.edgePoints[indexPath.row], index:indexPath.row, textDelegate:self)
               // cell.configure(edgePin:findMe.edgePoints[indexPath.row], index:indexPath.row, textDelegate:self)
                return cell
            }
        case SectionId.triangulationResult:
            if indexPath.row == 0 {
                if let cell = theTableView.dequeueReusableCell(withIdentifier: CellId.CenterCellId, for:indexPath) as? CenterTableViewCell {
                    cell.configure(coordinate:findMe.center!.coordinate)
                    return cell
                }
            } else {
                if let cell = theTableView.dequeueReusableCell(withIdentifier: CellId.DistanceFromBarycentreCellId, for: indexPath) as? DistanceFromBarycentreTableViewCell {
                    cell.configure(edgePin: findMe.edgePoints[indexPath.row - 1], center: findMe.center!)
                    return cell
                }
            }
        case SectionId.trianglePoints:
            if let cell = theTableView.dequeueReusableCell(withIdentifier: CellId.TriangleCellId, for: indexPath) as? DistanceTriangleTableViewCell {
                if let point = findMe.trianglePointFor(index:indexPath.row) {
                    cell.configure(point:point)
                } else {
                    cell.configure(error: NSLocalizedString("Unknown_Error", comment: ""))
                }
                
                return cell
            }
        default:
            break
        }
        
        return UITableViewCell()
    }
 }
