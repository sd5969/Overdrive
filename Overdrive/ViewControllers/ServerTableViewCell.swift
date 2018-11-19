//
//  ServerTableViewCell.swift
//  Overdrive
//
//  Created by Sanjit Dutta on 11/3/18.
//  Copyright © 2018 Sanjit Dutta. All rights reserved.
//

import UIKit

class ServerTableViewCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var nickname: UILabel!
    @IBOutlet weak var hostname: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
