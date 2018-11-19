//
//  AddTorrentViewController.swift
//  Overdrive
//
//  Created by Sanjit Dutta on 11/19/18.
//  Copyright © 2018 Sanjit Dutta. All rights reserved.
//

import UIKit
import os.log

class AddTorrentViewController: UIViewController {

    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var browseButton: UIButton!
    @IBOutlet weak var torrentPath: UILabel!
    
    var torrentFile: UIDocument?
    
    private func addTorrent() {
        return
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        browseButton.layer.cornerRadius = 4
        
//        let importMenu = UIDocumentPickerViewController(documentTypes: [UTType.kUTTypeItem as NSString],                                                 inMode: .Import)
//
//        importMenu.delegate = self
    }
    
    @IBAction func browsePressed(_ sender: UIButton) {
        
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
        addButton.isEnabled = (torrentFile != nil)
    }

}
