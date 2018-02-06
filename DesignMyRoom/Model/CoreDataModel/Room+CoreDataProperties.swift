//
//  Room+CoreDataProperties.swift
//  DesignMyRoom
//
//  Created by Andrew Delaney on 12/30/17.
//  Copyright © 2017 Andrew Delaney. All rights reserved.
//
//

import Foundation
import CoreData


extension Room {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Room> {
        return NSFetchRequest<Room>(entityName: "Room")
    }

    @NSManaged public var name: String?
    @NSManaged public var poster1: NSData?
    @NSManaged public var poster2: NSData?
    @NSManaged public var poster3: NSData?
    @NSManaged public var gender: String?
    @NSManaged public var createDate: NSDate?
    @NSManaged public var posterBin: PosterBin?

}
