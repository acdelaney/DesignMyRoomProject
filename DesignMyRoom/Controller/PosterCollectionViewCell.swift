//
//  PosterCollectionViewCell.swift
//  DesignMyRoom
//
//  Created by Andrew Delaney on 1/4/18.
//  Copyright © 2018 Andrew Delaney. All rights reserved.
//

import UIKit

class PosterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var posterImage: UIImageView!
    
    @IBOutlet weak var downloadActivityIndicator: UIActivityIndicatorView!
    
    
    // This is used to alter the image so that it is visible that it's selected.
    
    override var isSelected: Bool {
        didSet {
            self.contentView.backgroundColor = isSelected ? UIColor.blue : UIColor.yellow
            self.posterImage.alpha = isSelected ? 0.75 : 1.0
        }
    }
}
    
    

