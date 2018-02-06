//
//  Poster+CoreDataProperties.swift
//  DesignMyRoom
//
//  Created by Andrew Delaney on 12/30/17.
//  Copyright © 2017 Andrew Delaney. All rights reserved.
//
//

import Foundation
import CoreData


extension Poster {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Poster> {
        return NSFetchRequest<Poster>(entityName: "Poster")
    }

    @NSManaged public var posterImage: NSData?
    @NSManaged public var createDate: NSDate?
    @NSManaged public var posterBin: PosterBin?

}
