//
//  TorrentTableViewController.swift
//  Overdrive
//
//  Created by Sanjit Dutta on 11/11/18.
//  Copyright © 2018 Sanjit Dutta. All rights reserved.
//

import UIKit
import os.log

class TorrentTableViewController: UITableViewController {

    // MARK: Properties
    
    var torrents = [Torrent]()
    var server: Server? = nil
    
    private func loadSampleTorrents() {
        guard let path1 = Path(path: "/var/lib/torrents") else {
            fatalError("Could not instantiate path1")
        }
        guard let path2 = Path(path: "/var/lib/torrents/subdir") else {
            fatalError("Could not instantiate path1")
        }
        guard let torrent1 = Torrent(name: "Torrent 1", path: path1, addedDate: Date(), status: Torrent.Status.SEED) else {
            fatalError("Could not instantiate torrent1")
        }
        guard let torrent2 = Torrent(name: "Torrent 2", path: path2, addedDate: Date(), status: Torrent.Status.SEED) else {
            fatalError("Could not instantiate torrent2")
        }
        torrents += [torrent1, torrent2]
    }
    
    private func loadTorrents() {
        if self.server == nil {
            fatalError("Server is missing in TorrentTableViewController")
        }
        APIController.getSessionId(for: self.server!) { (result) in
            switch result {
            case .failure(let error):
                print("Unable to update session key, will not load torrents. Error was: \(error.localizedDescription).")
                self.loadSampleTorrents()
                return
            case .success(let sessionKey):
                if (!sessionKey.isEmpty) {
                    self.server!.sessionKey = sessionKey
                }
                APIController.getTorrents(for: self.server!) { (result) in
                    switch result {
                    case .success(let torrents):
                        self.torrents = torrents.sorted(by: { $0.addedDate > $1.addedDate })
                        self.tableView.reloadData()
                    case .failure(let error):
                        print("Error loading torrents: \(error.localizedDescription).")
                    }
                }
            }
        }
    }
    
    
    //MARK: Actions
    
    @IBAction func unwindToTorrentList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? PathTableViewController, let path = sourceViewController.selectedPath {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing torrent.
                torrents[selectedIndexPath.row].path = path
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let thisServer = server else {
            fatalError("Server is missing in TorrentTableViewController")
        }
        navigationItem.title = thisServer.nickname
        
        loadTorrents()
        
        self.tableView.rowHeight = 65.0
        
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
        return torrents.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "TorrentTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TorrentTableViewCell else {
            fatalError("The dequeued cell is not an instance of TorrentTableViewCell.")
        }
        
        // Fetches the appropriate server for the data source layout.
        let torrent = torrents[indexPath.row]
        
        cell.name.text = torrent.name
        cell.path.text = String(describing: torrent.path)

        return cell
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
            fatalError("The TorrentTableViewController is not inside a navigation controller.")
        }
    }
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "AddItem":
            os_log("Adding a new torrent.", log: OSLog.default, type: .debug)
            
        case "Show":
            guard let pathTableViewController = segue.destination as? PathTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedTorrentCell = sender as? TorrentTableViewCell else {
                fatalError("Unexpected sender: \(sender as Optional)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedTorrentCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedTorrent = torrents[indexPath.row]
            pathTableViewController.torrent = selectedTorrent
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier as Optional)")
        }
    }

}
