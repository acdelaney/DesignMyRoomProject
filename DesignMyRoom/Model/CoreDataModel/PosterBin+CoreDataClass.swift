//
//  PosterBin+CoreDataClass.swift
//  DesignMyRoom
//
//  Created by Andrew Delaney on 12/30/17.
//  Copyright © 2017 Andrew Delaney. All rights reserved.
//
//

import Foundation
import CoreData


public class PosterBin: NSManagedObject {

    // MARK: Initializer
    
    convenience init(context: NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "PosterBin", in: context) {
            self.init(entity: ent, insertInto: context)
            self.createDate = NSDate()
            
        } else {
            
            fatalError("Unable to find Entity name!")
        }
    }
    
    
    
}
