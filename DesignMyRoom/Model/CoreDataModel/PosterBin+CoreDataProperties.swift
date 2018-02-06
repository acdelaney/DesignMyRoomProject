//
//  PosterBin+CoreDataProperties.swift
//  DesignMyRoom
//
//  Created by Andrew Delaney on 12/30/17.
//  Copyright © 2017 Andrew Delaney. All rights reserved.
//
//

import Foundation
import CoreData


extension PosterBin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PosterBin> {
        return NSFetchRequest<PosterBin>(entityName: "PosterBin")
    }

    @NSManaged public var createDate: NSDate?
    @NSManaged public var room: Room?
    @NSManaged public var poster: NSSet?

}

// MARK: Generated accessors for poster
extension PosterBin {

    @objc(addPosterObject:)
    @NSManaged public func addToPoster(_ value: Poster)

    @objc(removePosterObject:)
    @NSManaged public func removeFromPoster(_ value: Poster)

    @objc(addPoster:)
    @NSManaged public func addToPoster(_ values: NSSet)

    @objc(removePoster:)
    @NSManaged public func removeFromPoster(_ values: NSSet)

}
