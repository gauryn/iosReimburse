//
//  OrgRoleFormViewController.swift
//  Reimburse Final Project
//
//  Created by Gaury Nagaraju on 12/5/16.
//
//

import UIKit
import Alamofire
import SwiftyJSON

class OrgRoleFormViewController: UIViewController, UIPickerViewDelegate {

    // MARK: Properties
    @IBOutlet weak var org: UITextField!
    @IBOutlet weak var role: UITextField!
    
    var orgs = Array<String>()
    var roles = ["Member", "Signer", "Primary Contact"]
    
    // Nav Bar Button Actions
    @IBAction func cancel(_ sender: Any) {
        self.performSegue(withIdentifier: "showOrgRoleList", sender: self)
    }
    @IBAction func submit(_ sender: Any) {
        // Get Parameters
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        let today = Date()
        let sdString = dateFormatter.string(from: today)
        let sd = dateFormatter.date(from: sdString)
        
        let parameters: Parameters = [
            "user_org":[
                "organization": org.text!,
                "role": role.text!,
                "start_date": sd!,
                "user_id": 1
            ]
        ]
        // API Call to create new UserOrg
        Alamofire.request("https://reimbursementapi.herokuapp.com/user_orgs/", method: .post, parameters: parameters).validate().responseJSON { response in
            
            switch response.result {
            case .success:
                print("Successful Request")
                // Reload Table
                // Segue to Screen: list of orgs & roles
                self.performSegue(withIdentifier: "showOrgRoleList", sender: self)
                
            case .failure(let error):
                print(error)
                // Display Error
                let msg = "Error while submitting request. \nPlease try again."
                let alert = UIAlertController(title: "Error", message: msg, preferredStyle: UIAlertControllerStyle.alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(defaultAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func loadAllOrgs(completionHandler: @escaping (Bool?, NSError?) -> ()){
        var isLoading = true
        // API Call to authenticate user
        Alamofire.request("https://reimbursementapi.herokuapp.com/organizations", method: .get).validate().responseJSON { response in
            switch response.result {
            case .failure(let error):
                // IDEAL CASE: SHOULD NEVER REACH FAILURE CASE
                print("Error: ", error)
                isLoading = true
                completionHandler(isLoading, error as NSError?)
            case .success(let value):
                print("Successful Request")
                let json = JSON(value)
                print("Json: ", json)
                // Loop through orgs
                for (key,subJson):(String, JSON) in json {
                    self.orgs.append(subJson["name"].stringValue)
                }
                isLoading = false
                completionHandler(isLoading, nil)
            } // End of AlamoFire Request Result
        }// End of Alamofire Request
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Status Bar Appearance
        UIApplication.shared.statusBarStyle = .lightContent
        
        // Dropdown Views
        // Load Orgs
        loadAllOrgs{
            (isLoading, error) in
            if isLoading == false{
                let orgPickerView = UIPickerView()
                orgPickerView.tag = 0
                orgPickerView.delegate = self
                orgPickerView.reloadAllComponents()
                self.org.inputView = orgPickerView
            }
            else{
                // Do nothing
            }
            
        }
        
        let rolePickerView = UIPickerView()
        rolePickerView.tag = 1
        rolePickerView.delegate = self
        rolePickerView.selectRow(0, inComponent: 0, animated: true)
        role.inputView = rolePickerView
        
    }
    
    override func viewWillAppear(_ animated: Bool) {

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - PickerView Delegate Methods
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0{
            return orgs.count
        }
        else if pickerView.tag == 1{
            return roles.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0{
            return orgs[row]
        }
        else if pickerView.tag == 1{
            return roles[row]
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        org.text = orgs[row]
        if pickerView.tag == 0{
            org.text = orgs[row]
        }
        else if pickerView.tag == 1{
            role.text = roles[row]
        }
    }
    
    // Resign TextField as First Responder
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}
