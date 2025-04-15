//
//  WorkoutDay+Preview.swift
//  IronTrack
//
//  Created by Jakub Marcinkowski on 08/04/2025.
//

import Foundation
import CoreData

extension WorkoutDay {
    static func preview(in context: NSManagedObjectContext) -> WorkoutDay {
        let day = WorkoutDay(context: context)
        day.name = "Środa"
        day.date = Date()

        let exercise = Exercise(context: context)
        exercise.name = "Wyciskanie sztangi"
        exercise.reps = 10
        exercise.sets = 4
        exercise.date = Date()
        exercise.workoutDay = day

        return day
    }
}
