import SwiftUI
import CoreData

struct ExerciseListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var workoutDay: WorkoutDay

    @State private var exerciseName = ""
    @State private var note = ""
    @State private var reps = ""
    @State private var sets = ""
    @State private var exerciseDate = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dodaj ćwiczenie")
                .font(.title2)
                .bold()

            DatePicker("Data", selection: $exerciseDate, displayedComponents: [.date])

            TextField("Nazwa ćwiczenia", text: $exerciseName)
                .textFieldStyle(.roundedBorder)

            TextField("Powtórzenia", text: $reps)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardTypeCompat(.numberPad)

            TextField("Serie", text: $sets)
                .textFieldStyle(.roundedBorder)
                .keyboardTypeCompat(.numberPad)

            TextField("Notatka (opcjonalnie)", text: $note)
                .textFieldStyle(.roundedBorder)

            Button("Dodaj ćwiczenie") {
                addExercise()
            }
            .disabled(exerciseName.isEmpty || Int(reps) == nil || Int(sets) == nil)
            .buttonStyle(.borderedProminent)
            .padding(.top)

            Spacer()
        }
        .padding()
        .navigationTitle("Nowe ćwiczenie")
    }

    private func addExercise() {
        guard let context = workoutDay.managedObjectContext else {
            print("Brak kontekstu dla workoutDay")
            return
        }

        let exercise = Exercise(context: context)
        exercise.name = exerciseName
        exercise.reps = Int16(reps) ?? 0
        exercise.sets = Int16(sets) ?? 0
        exercise.note = note
        exercise.date = exerciseDate
        exercise.workoutDay = workoutDay

        do {
            try context.save()
            // Czyścimy formularz
            exerciseName = ""
            note = ""
            reps = ""
            sets = ""
            exerciseDate = Date()
            dismiss() // Zamyka widok po zapisaniu
        } catch {
            print("❌ Błąd zapisu: \(error.localizedDescription)")
        }
    }
}
