import SwiftUI
import CoreData

struct ExerciseEditView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var exercise: Exercise
    var onSave: (() -> Void)? = nil

    @State private var name: String = ""
    @State private var reps: String = ""
    @State private var sets: String = ""
    @State private var note: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edytuj ćwiczenie")) {
                    TextField("Nazwa", text: $name)
                    TextField("Powtórzenia", text: $reps)
                        .keyboardTypeCompat(.numberPad)
                    TextField("Serie", text: $sets)
                        .keyboardTypeCompat(.numberPad)
                    TextField("Notatka", text: $note)
                }

                Button("Zapisz zmiany") {
                    updateExercise()
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("Edytuj ćwiczenie")
            .onAppear {
                name = exercise.name ?? ""
                reps = String(exercise.reps)
                sets = String(exercise.sets)
                note = exercise.note ?? ""
            }
        }
    }

    private func updateExercise() {
        exercise.name = name
        exercise.reps = Int16(reps) ?? 0
        exercise.sets = Int16(sets) ?? 0
        exercise.note = note

        do {
            try viewContext.save()
            dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                onSave?()
            }
        } catch {
            print("❌ Błąd zapisu edycji: \(error.localizedDescription)")
        }
    }
}
