//
//  PathTableViewController.swift
//  Overdrive
//
//  Created by Sanjit Dutta on 11/11/18.
//  Copyright © 2018 Sanjit Dutta. All rights reserved.
//

import UIKit
import os.log

class PathTableViewController: UITableViewController {

    // MARK: Properties
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    var paths = [Path]()
    var torrent: Torrent? = nil
    var server: Server? = nil
    var selectedPath: Path? = nil
    
    private func loadSamplePaths() {
        guard let path1 = Path(path: "/var/lib/torrents") else {
            fatalError("Could not instantiate path1")
        }
        guard let path2 = Path(path: "/var/lib/torrents/subdir") else {
            fatalError("Could not instantiate path1")
        }
        paths += [path1, path2]
    }
    
    private func updateTorrentPath() {
        if self.server == nil || self.torrent == nil {
            fatalError("Server / Torrent is missing in PathTableViewController")
        }
        if self.selectedPath == nil {
            print("Not updating path, nothing selected")
            return
        }
        APIController.getSessionId(for: self.server!) { (result) in
            switch result {
            case .failure(let error):
                print("Unable to update session key, will not load torrents. Error was: \(error.localizedDescription).")
                let alert = UIAlertController(title: "Error", message: "Unable to update session key, will not load torrents.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Oh well", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            case .success(let sessionKey):
                print("Updating session key")
                if (!sessionKey.isEmpty) {
                    self.server!.sessionKey = sessionKey
                }
                APIController.updateTorrentPath(server: self.server!, torrent: self.torrent!, path: self.selectedPath!) { (result) in
                    switch result {
                    case .success(let success):
                        if !success {
                            print("Error updating torrent path.")
                            let alert = UIAlertController(title: "Error", message: "Torrent path update unsuccessful", preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "Oh well", style: UIAlertAction.Style.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                        print("Updated torrent path")
                    case .failure(let error):
                        print("Error loading torrents: \(error.localizedDescription).")
                        let alert = UIAlertController(title: "Error", message: "Error updating torrent path", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "Click", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // loadSamplePaths()
        
        guard let thisTorrent = torrent else {
            fatalError("Torrent is missing in PathTableViewController")
        }
        navigationItem.title = thisTorrent.name
        updateSaveState()
        
        self.tableView.rowHeight = 35.0

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return paths.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "PathTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PathTableViewCell  else {
            fatalError("The dequeued cell is not an instance of PathTableViewCell.")
        }
        
        // Fetches the appropriate server for the data source layout.
        let path = paths[indexPath.row]
        
        cell.path.text = String(describing: path)
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPath = paths[indexPath.row]
        updateSaveState()
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    //MARK: Navigation
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The PathTableViewController is not inside a navigation controller.")
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
        
        self.updateTorrentPath()
    }
    
    func updateSaveState() {
        saveButton.isEnabled = (self.selectedPath != nil)
    }
}
