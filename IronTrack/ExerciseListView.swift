import SwiftUI
import CoreData

struct ExerciseListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var workoutDay: WorkoutDay
    var onSave: (() -> Void)? = nil

    @State private var exerciseName = ""
    @State private var reps = ""
    @State private var sets = ""
    @State private var note = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Nowe ćwiczenie")) {
                    TextField("Nazwa", text: $exerciseName)
                    TextField("Powtórzenia", text: $reps)
                        .keyboardTypeCompat(.numberPad)
                    TextField("Serie", text: $sets)
                        .keyboardTypeCompat(.numberPad)
                    TextField("Notatka (opcjonalnie)", text: $note)
                }

                Button("Dodaj ćwiczenie") {
                    addExercise()
                }
                .disabled(exerciseName.isEmpty || Int(reps) == nil || Int(sets) == nil)
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("Dodaj ćwiczenie")
        }
    }

    private func addExercise() {
        let exercise = Exercise(context: viewContext)
        exercise.name = exerciseName
        exercise.reps = Int16(reps) ?? 0
        exercise.sets = Int16(sets) ?? 0
        exercise.note = note
        exercise.date = Date()
        exercise.workoutDay = workoutDay

        do {
            try viewContext.save()
            onSave?()
            dismiss()
        } catch {
            print("❌ Błąd zapisu ćwiczenia: \(error.localizedDescription)")
        }
    }
}
