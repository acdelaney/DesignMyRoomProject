//
//  roundedCornerButton.swift
//  DesignMyRoom
//
//  Created by Andrew Delaney on 1/23/18.
//  Copyright © 2018 Andrew Delaney. All rights reserved.
//

import UIKit

class roundedCornerButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 10
        
        
    }

}
