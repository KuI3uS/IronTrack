//
//  ExerciseListView.swift
//  IronTrack
//
//  Created by Jakub Marcinkowski on 08/04/2025.
//

import SwiftUI
import CoreData

struct ExerciseListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var workoutDay: WorkoutDay

    @State private var exerciseName: String = ""
    @State private var reps: String = ""
    @State private var sets: String = ""
    @State private var exerciseDate: Date = Date()

    var body: some View {
        VStack(alignment: .leading) {
            Text("Dodaj ćwiczenie")
                .font(.headline)

            DatePicker("Data ćwiczenia", selection: $exerciseDate, displayedComponents: [.date])
            TextField("Nazwa ćwiczenia", text: $exerciseName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Powtórzenia", text: $reps)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Dodaj") {
                addExercise()
            }
            .padding(.vertical)

            Divider()

            Text("Ćwiczenia")
                .font(.title2)

            if let exercises = (workoutDay.exercises?.allObjects as? [Exercise])?.sorted(by: { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) }) {
                if exercises.isEmpty {
                    Text("Brak ćwiczeń")
                        .foregroundColor(.gray)
                        .italic()
                } else {
                    List {
                        ForEach(exercises, id: \.self) { exercise in
                            ExerciseRowView(exercise: exercise)
                        }
                        .onDelete(perform: deleteExercise)
                    }
                }
            } else {
                Text("Brak ćwiczeń")
            }
        }
        .padding()
        .navigationTitle(workoutDay.name ?? "Trening")
    }

    private func addExercise() {
        withAnimation {
            let newExercise = Exercise(context: viewContext)
            newExercise.name = exerciseName
            newExercise.reps = Int16(reps) ?? 0
            newExercise.sets = Int16(sets) ?? 0
            newExercise.date = exerciseDate
            newExercise.workoutDay = workoutDay

            do {
                try viewContext.save()
                exerciseName = ""
                reps = ""
                sets = ""
            } catch {
                print("Błąd zapisu ćwiczenia: \(error.localizedDescription)")
            }
        }
    }

    private func deleteExercise(at offsets: IndexSet) {
        if let exercises = (workoutDay.exercises?.allObjects as? [Exercise])?.sorted(by: { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) }) {
            for index in offsets {
                viewContext.delete(exercises[index])
            }
            try? viewContext.save()
        }
    }
}

struct ExerciseRowView: View {
    var exercise: Exercise

    var body: some View {
        VStack(alignment: .leading) {
            Text(exercise.name ?? "")
                .font(.headline)

            Text("Powtórzeń: \(exercise.reps) / Serie: \(exercise.sets)")

            if let date = exercise.date {
                Text("Data: \(date.formatted(.dateTime.day().month().year()))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ExerciseListView(workoutDay: WorkoutDay.preview)
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
