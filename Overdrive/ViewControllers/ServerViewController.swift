//
//  ServerViewController.swift
//  Overdrive
//
//  Created by Sanjit Dutta on 10/30/18.
//  Copyright © 2018 Sanjit Dutta. All rights reserved.
//

import UIKit
import os.log

class ServerViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: Properties
    @IBOutlet weak var nickname: UITextField!
    @IBOutlet weak var hostname: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var port: UITextField!
    @IBOutlet weak var rootDirectory: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    /*
     This value is either passed by `ServerTableViewController` in `prepare(for:sender:)`
     or constructed as part of adding a new server.
     */
    var server: Server?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field’s user input through delegate callbacks.
        nickname.delegate = self
        hostname.delegate = self
        username.delegate = self
        password.delegate = self
        port.delegate = self
        rootDirectory.delegate = self
        
        // Set up views if editing an existing Server.
        if let server = server {
            navigationItem.title = server.nickname
            nickname.text = server.nickname
            hostname.text = server.hostname
            username.text = server.username
            password.text = server.password
            port.text = String(server.port)
            rootDirectory.text = server.rootDirectory
        }
        
        // Enable the Save button only if the text field has a valid Server hostname.
        updateSaveButtonState()
    }

    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard if last field
        if textField === rootDirectory {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField === hostname && !(hostname.text ?? "").isEmpty {
            nickname.text = hostname.text
            navigationItem.title = textField.text
        }
        
        if textField === nickname && !(nickname.text ?? "").isEmpty {
            navigationItem.title = textField.text
        }
        updateSaveButtonState()
    }
    
    //MARK: Navigation
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddServerMode = presentingViewController is UINavigationController
        
        if isPresentingInAddServerMode {
            dismiss(animated: true, completion: nil)
        }
        
        else if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        }
        
        else {
            fatalError("The ServerViewController is not inside a navigation controller.")
        }
    }
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        guard let hostnameVal = hostname.text else {
            fatalError("Hostname MUST be set")
        }
        let nicknameVal = nickname.text
        let usernameVal = username.text
        let passwordVal = password.text
        let portVal = Int(port.text ?? "9091")
        let rootDirectoryVal = rootDirectory.text ?? nil
        
        // Set the server to be passed to ServerTableViewController after the unwind segue.
        server = Server(nickname: nicknameVal, hostname: hostnameVal, username: usernameVal, password: passwordVal, port: portVal, rootDirectory: rootDirectoryVal, sessionKey: "")
    }
    
    //MARK: Private Methods
    
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = hostname.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
}

