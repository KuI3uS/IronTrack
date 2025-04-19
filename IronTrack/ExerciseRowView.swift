//
//  ExerciseRowView.swift
//  IronTrack
//
//  Created by Jakub Marcinkowski on 16/04/2025.
//

import SwiftUI

struct ExerciseRowView: View {
    @ObservedObject var exercise: Exercise
    let onToggle: () -> Void

    var body: some View {
        HStack {
            Button {
                withAnimation {
                    exercise.isCompleted.toggle()
                    onToggle()
                }
            } label: {
                Image(systemName: exercise.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(exercise.isCompleted ? .green : .gray)
                    .imageScale(.large)
            }

            VStack(alignment: .leading) {
                Text(exercise.name ?? "")
                    .font(.headline)
                Text("Powtórzeń: \(exercise.reps) / Serie: \(exercise.sets)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                if let note = exercise.note, !note.isEmpty {
                    Text(note)
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
            }
        }
    }
}
