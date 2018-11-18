//
//  ServerTableViewController.swift
//  Overdrive
//
//  Created by Sanjit Dutta on 11/3/18.
//  Copyright © 2018 Sanjit Dutta. All rights reserved.
//

import UIKit
import os.log

class ServerTableViewController: UITableViewController {
    
    //MARK: Properties
    
    var servers = [Server]()
    
    //MARK: Actions
    
    @IBAction func unwindToServerList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? ServerViewController, let server = sourceViewController.server {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing server.
                servers[selectedIndexPath.row] = server
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            
            else {
                // Add a new server.
                let newIndexPath = IndexPath(row: servers.count, section: 0)
                servers.append(server)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            
            // Save the servers.
            saveServers()
        }
    }
    
    @IBAction func unwindToServerListFromTorrent(sender: UIStoryboardSegue) {}
    
    //MARK: Private Methods
    
    private func loadSampleServers() {
        
        guard let server1 = Server(nickname: nil, hostname: "testserver1.com", username: nil, password: nil, port: nil, rootDirectory: nil, sessionKey: nil) else {
            fatalError("Unable to instantiate server1")
        }
        
        guard let server2 = Server(nickname: nil, hostname: "testserver2.com", username: nil, password: nil, port: nil, rootDirectory: nil, sessionKey: nil) else {
            fatalError("Unable to instantiate server2")
        }
        
        guard let server3 = Server(nickname: nil, hostname: "testserver3.com", username: nil, password: nil, port: nil, rootDirectory: nil, sessionKey: nil) else {
            fatalError("Unable to instantiate server3")
        }
        
        servers += [server1, server2, server3]
        
    }
    
    private func saveServers() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(servers, toFile: Server.ArchiveURL.path)
        
        if isSuccessfulSave {
            os_log("Servers successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save server...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadServers() -> [Server]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Server.ArchiveURL.path) as? [Server]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem
        
        // Allow selection during editing. Don't think this is the right way to do it
        // tableView.allowsSelectionDuringEditing = true
        
        // Load any saved servers, otherwise load sample data.
        if let savedServers = loadServers() {
            servers += savedServers
        }
        
        else {
            // Load the sample data.
            loadSampleServers()
        }
        
        self.tableView.rowHeight = 65.0
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return servers.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "ServerTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ServerTableViewCell  else {
            fatalError("The dequeued cell is not an instance of ServerTableViewCell.")
        }
        
        // Fetches the appropriate server for the data source layout.
        let server = servers[indexPath.row]

        cell.nickname.text = server.nickname
        cell.hostname.text = server.hostname

        return cell
    }
    

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            servers.remove(at: indexPath.row)
            saveServers()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
        
        
    }

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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "AddItem":
            os_log("Adding a new server.", log: OSLog.default, type: .debug)
        
        case "Show":
            guard let torrentTableViewController = segue.destination as? TorrentTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedServerCell = sender as? ServerTableViewCell else {
                fatalError("Unexpected sender: \(sender as Optional)")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedServerCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedServer = servers[indexPath.row]
            torrentTableViewController.server = selectedServer
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier as Optional)")
        }
    }

}
