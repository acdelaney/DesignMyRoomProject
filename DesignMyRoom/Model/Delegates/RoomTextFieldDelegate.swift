//
//  RoomTextFieldDelegate.swift
//  DesignMyRoom
//
//  Created by Andrew Delaney on 12/30/17.
//  Copyright © 2017 Andrew Delaney. All rights reserved.
//

import Foundation
import UIKit

class RoomTextFieldDelegate: NSObject, UITextFieldDelegate {
    
    
    //resign keyboard on return
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true;
    }
    
    
    
}
