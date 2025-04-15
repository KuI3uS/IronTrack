//
//  Exercise+CoreDataProperties.swift
//  IronTrack
//
//  Created by Jakub Marcinkowski on 15/04/2025.
//
//

import Foundation
import CoreData


extension Exercise {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Exercise> {
        return NSFetchRequest<Exercise>(entityName: "Exercise")
    }

    @NSManaged public var date: Date?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var name: String?
    @NSManaged public var note: String?
    @NSManaged public var reps: Int16
    @NSManaged public var sets: Int16
    @NSManaged public var workoutDay: WorkoutDay?

}

extension Exercise : Identifiable {

}
