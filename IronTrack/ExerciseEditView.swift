//
//  ExerciseEditView.swift
//  IronTrack
//
//  Created by Jakub Marcinkowski on 19/04/2025.
//

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
        Form {
            Section(header: Text("Ćwiczenie")) {
                TextField("Nazwa", text: $name)
                TextField("Powtórzenia", text: $reps)
                    .keyboardTypeCompat(.numberPad)
                TextField("Serie", text: $sets)
                    .keyboardTypeCompat(.numberPad)
                TextField("Notatka", text: $note)
            }

            Button("Zapisz zmiany") {
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
                    print("❌ Błąd zapisu: \(error.localizedDescription)")
                }
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
