//
//  Torrent.swift
//  Overdrive
//
//  Created by Sanjit Dutta on 11/11/18.
//  Copyright © 2018 Sanjit Dutta. All rights reserved.
//

import UIKit

class Torrent {
    
    // from https://github.com/FLYBYME/node-transmission
    enum Status: Int {
        case STOPPED,  // : 0  # Torrent is stopped
        CHECK_WAIT,    // : 1  # Queued to check files
        CHECK,         // : 2  # Checking files
        DOWNLOAD_WAIT, // : 3  # Queued to download
        DOWNLOAD,      // : 4  # Downloading
        SEED_WAIT,     // : 5  # Queued to seed
        SEED,          // : 6  # Seeding
        ISOLATED,      // : 7  # Torrent can't find peers
        UNKNOWN
    }
    
    //MARK: Properties
    var name: String
    var path: Path
    var addedDate: Date
    var status: Status
    var id: Int
    
    init?(name: String, path: Path, addedDate: Date, status: Int, id: Int) {
        self.name = name
        self.path = path
        self.addedDate = addedDate
        self.status = Status(rawValue: status) ?? Status.UNKNOWN
        self.id = id
    }
    
    init?(name: String, path: Path, addedDate: Date, status: Status, id: Int) {
        self.name = name
        self.path = path
        self.addedDate = addedDate
        self.status = status
        self.id = id
    }
}
