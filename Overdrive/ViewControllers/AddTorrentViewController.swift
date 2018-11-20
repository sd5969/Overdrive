//
//  AddTorrentViewController.swift
//  Overdrive
//
//  Created by Sanjit Dutta on 11/19/18.
//  Copyright © 2018 Sanjit Dutta. All rights reserved.
//

import UIKit
import MobileCoreServices
import os.log

class AddTorrentViewController: UIViewController, UIDocumentPickerDelegate {

    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var browseButton: UIButton!
    @IBOutlet weak var torrentPath: UILabel!
    
    var torrentData: Data?
    var server: Server?
    
    private func addTorrent() {
        if torrentData == nil || server == nil {
            return
        }
        
        APIController.getSessionId(for: self.server!) { (result) in
            switch result {
            case .failure(let error):
                print("Unable to update session key, will not add torrent. Error was: \(error.localizedDescription).")
                let alert = UIAlertController(title: "Error", message: "Unable to update session key, will not add torrent.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Oh well", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            case .success(let sessionKey):
                print("Updating session key")
                if (!sessionKey.isEmpty) {
                    self.server!.sessionKey = sessionKey
                }
                APIController.addTorrent(server: self.server!, torrentData: self.torrentData!) { (result) in
                    switch result {
                    case .success(let success):
                        if !success {
                            print("Error adding torrent.")
                            let alert = UIAlertController(title: "Error", message: "Torrent add unsuccessful", preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "Oh well", style: UIAlertAction.Style.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                        print("Added torrent")
                    case .failure(let error):
                        print("Error adding torrent: \(error.localizedDescription).")
                        let alert = UIAlertController(title: "Error", message: "Error adding torrent", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Oh well", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        browseButton.layer.cornerRadius = 4
    }
    
    @IBAction func browsePressed(_ sender: UIButton) {
        let importMenu = UIDocumentPickerViewController(documentTypes: [kUTTypeItem as String], in: .import)
        importMenu.delegate = self
        present(importMenu, animated: true, completion: nil)
    }
    
    // MARK: UIDocumentPickerDelegate
    
    /*
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        dismiss(animated: true, completion: nil) // this is double cancelling?
    }
    */
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if urls.count == 0 {
            return
        }
        if urls.count > 1 {
            let alert = UIAlertController(title: "Notice", message: "Only the first file selected will be added.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Oh well", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        do {
            self.torrentData = try Data(contentsOf: urls[0])
            torrentPath.text = urls[0].lastPathComponent
        } catch {
            fatalError("Unable to load data from file.")
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === addButton else {
            os_log("The add button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        self.addTorrent()
    }
    
    func updateAddState() {
        addButton.isEnabled = (torrentData != nil)
    }

}
