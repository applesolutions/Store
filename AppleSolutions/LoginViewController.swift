//
//  LoginViewController.swift
//  Sample App Customers
//
//  Created by Shopify.
//  Copyright (c) 2016 Shopify Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit
//import Buy

class LoginViewController: UITableViewController {

    weak var delegate: AuthenticationDelegate?
    
    @IBOutlet fileprivate weak var emailField:    UITextField!
    @IBOutlet fileprivate weak var passwordField: UITextField!
    @IBOutlet fileprivate weak var actionCell:    ActionCell!
    
    fileprivate var email:    String { return self.emailField.text    ?? "" }
    fileprivate var password: String { return self.passwordField.text ?? "" }
    
    // ----------------------------------
    //  MARK: - View Loading -
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.actionCell.loading = false
        if (UserDefaults.standard.object(forKey: "username_shopifyLogin") != nil) && (UserDefaults.standard.object(forKey: "password_shopifyLogin") != nil){
            
            let username = UserDefaults.standard.object(forKey: "username_shopifyLogin");
            let password = UserDefaults.standard.object(forKey: "password_shopifyLogin")
            let credentials  = BUYAccountCredentials(items: [
                BUYAccountCredentialItem(email: username as! String),
                BUYAccountCredentialItem(password: password as! String),
                ])
            
   
        
        self.actionCell.loading = true
        APSShopifyBuyManager.sharedInstance().m_client.loginCustomer(with: credentials) { (customer, token, error) in
            self.actionCell.loading = false
            
            if let customer = customer,
                let token = token {
                self.clear()
                self.delegate?.authenticationDidSucceedForCustomer(customer, withToken: token.accessToken)
            } else {
                self.delegate?.authenticationDidFailWithError(error as NSError?)
            }
        }
        }
    }
    
    // ----------------------------------
    //  MARK: - Actions -
    //
    fileprivate func loginUser() {
        guard !self.actionCell.loading else { return }
        
      
        let credentials  = BUYAccountCredentials(items: [
            BUYAccountCredentialItem(email: self.email),
            BUYAccountCredentialItem(password: self.password),
        ])
        
        self.actionCell.loading = true
        APSShopifyBuyManager.sharedInstance().m_client.loginCustomer(with: credentials) { (customer, token, error) in
            self.actionCell.loading = false
            UserDefaults.standard.set(self.email, forKey: "username_shopifyLogin")
            UserDefaults.standard.set(self.password, forKey: "password_shopifyLogin")

            if let customer = customer,
                let token = token {
                self.clear()
                self.delegate?.authenticationDidSucceedForCustomer(customer, withToken: token.accessToken)
            } else {
                self.delegate?.authenticationDidFailWithError(error as NSError?)
            }
        }
    }
    
    fileprivate func clear() {
        self.emailField.text     = ""
        self.passwordField.text  = ""
    }
    
    // ----------------------------------
    //  MARK: - UITableViewDelegate -
    //
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 1 {
            
            if !self.email.isEmpty &&
                !self.password.isEmpty {
                
                self.loginUser()
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
