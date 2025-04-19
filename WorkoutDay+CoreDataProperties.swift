//
//  WorkoutDay+CoreDataProperties.swift
//  IronTrack
//
//  Created by Jakub Marcinkowski on 19/04/2025.
//
//

import Foundation
import CoreData


extension WorkoutDay {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutDay> {
        return NSFetchRequest<WorkoutDay>(entityName: "WorkoutDay")
    }

    @NSManaged public var date: Date?
    @NSManaged public var name: String?
    @NSManaged public var note: String?
    @NSManaged public var exercises: NSSet?

}

// MARK: Generated accessors for exercises
extension WorkoutDay {

    @objc(addExercisesObject:)
    @NSManaged public func addToExercises(_ value: Exercise)

    @objc(removeExercisesObject:)
    @NSManaged public func removeFromExercises(_ value: Exercise)

    @objc(addExercises:)
    @NSManaged public func addToExercises(_ values: NSSet)

    @objc(removeExercises:)
    @NSManaged public func removeFromExercises(_ values: NSSet)

}

extension WorkoutDay : Identifiable {

}
