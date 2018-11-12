//
//  Path.swift
//  Overdrive
//
//  Created by Sanjit Dutta on 11/11/18.
//  Copyright © 2018 Sanjit Dutta. All rights reserved.
//

import UIKit

class Path: CustomStringConvertible {
    
    // MARK: Properties
    
    var path: String
    
    public var description: String {
        return self.path
    }
    
    init?(path: String) {
        self.path = path
    }
}
