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
            TextField("Powtórzenia", text: $reps)
            TextField("Serie", text: $sets)

            Button("Dodaj") {
                addExercise()
            }
            .padding(.vertical)

            Divider()

            Text("Ćwiczenia")
                .font(.title2)
            
           

            if let exercises = workoutDay.exercises?.allObjects as? [Exercise] {
                List {
                    ForEach(exercises, id: \.self) { exercise in
                        VStack(alignment: .leading) {
                            Text(exercise.name ?? "")
                                .font(.headline)
                            Text("Powtórzeń: \(exercise.reps) / Serie: \(exercise.sets)")
                        }
                    }
                    .onDelete(perform: deleteExercise)
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
               newExercise.data = exerciseDate
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
           if let exercises = workoutDay.exercises?.allObjects as? [Exercise] {
               for index in offsets {
                   let exercise = exercises[index]
                   viewContext.delete(exercise)
               }
               try? viewContext.save()
           }
       }
   }
#Preview {
    ExerciseListView(workoutDay: WorkoutDay.preview)
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
