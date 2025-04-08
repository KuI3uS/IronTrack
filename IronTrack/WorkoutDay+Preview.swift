//
//  WorkoutDay+Preview.swift
//  IronTrack
//
//  Created by Jakub Marcinkowski on 08/04/2025.
//

import Foundation
import CoreData

extension WorkoutDay {
    static var preview: WorkoutDay {
        let context = PersistenceController.preview.container.viewContext
        let day = WorkoutDay(context: context)
        day.name = "Dzień przykładowy"
        day.date = Date()

        // Dodaj przykładowe ćwiczenia
        let exercise = Exercise(context: context)
        exercise.name = "Martwy ciąg"
        exercise.reps = 5
        exercise.sets = 4
        exercise.workoutDay = day

        return day
    }
}
