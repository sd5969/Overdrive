//
//  Torrent.swift
//  Overdrive
//
//  Created by Sanjit Dutta on 11/11/18.
//  Copyright © 2018 Sanjit Dutta. All rights reserved.
//

import UIKit

class Torrent {
    
    //MARK: Properties
    var name: String
    var path: Path
    
    init?(name: String, path: Path) {
        self.name = name
        self.path = path
    }
}
