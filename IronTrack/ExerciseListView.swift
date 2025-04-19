import SwiftUI
import CoreData

struct ExerciseListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var workoutDay: WorkoutDay
    var onSave: (() -> Void)? = nil

    @State private var exerciseName = ""
    @State private var note = ""
    @State private var reps = ""
    @State private var sets = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dodaj ćwiczenie")
                .font(.title2)
                .bold()

            TextField("Nazwa ćwiczenia", text: $exerciseName)
                .textFieldStyle(.roundedBorder)

            TextField("Powtórzenia", text: $reps)
                .keyboardTypeCompat(.numberPad)
                .textFieldStyle(.roundedBorder)

            TextField("Serie", text: $sets)
                .keyboardTypeCompat(.numberPad)
                .textFieldStyle(.roundedBorder)

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
        let exercise = Exercise(context: viewContext)
        exercise.name = exerciseName
        exercise.reps = Int16(reps) ?? 0
        exercise.sets = Int16(sets) ?? 0
        exercise.note = note
        exercise.date = workoutDay.date
        exercise.workoutDay = workoutDay

        do {
            try viewContext.save()
            print("✅ Ćwiczenie zapisane")
            onSave?()
            dismiss()
        } catch {
            print("❌ Błąd zapisu: \(error.localizedDescription)")
        }
    }
}
