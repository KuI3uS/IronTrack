import SwiftUI
import CoreData

struct WorkoutDayDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var workoutDay: WorkoutDay

    @State private var exercises: [Exercise] = []
    @State private var dayNote: String = ""
    @State private var showAlert = false
    @State private var showExerciseSheet = false

    var completedCount: Int {
        exercises.filter { $0.isCompleted }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(workoutDay.name ?? "Trening")
                .font(.title)

            if let date = workoutDay.date {
                Text(date.formatted(.dateTime.day().month().year()))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Text("Notatka")
                .font(.headline)

            TextEditor(text: $dayNote)
                .onChange(of: dayNote) {
                    workoutDay.note = dayNote
                    save()
                }
                .frame(height: 100)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))

            Text("Wykonane ćwiczenia: \(completedCount)/\(exercises.count)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button {
                showExerciseSheet = true
            } label: {
                Label("Dodaj ćwiczenie", systemImage: "plus.circle")
            }
            .sheet(isPresented: $showExerciseSheet) {
                ExerciseListView(workoutDay: workoutDay)
                    .environment(\.managedObjectContext, viewContext)
            }

            if exercises.isEmpty {
                Text("Brak ćwiczeń")
                    .foregroundColor(.gray)
                    .italic()
            } else {
                List {
                    ForEach(exercises) { exercise in
                        HStack {
                            Button {
                                exercise.isCompleted.toggle()
                                save()
                                loadExercises()
                            } label: {
                                Image(systemName: exercise.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(exercise.isCompleted ? .green : .gray)
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
                    .onDelete(perform: deleteExercise)
                }
            }

            Button("Zakończ dzień") {
                for i in exercises.indices {
                    exercises[i].isCompleted = true
                }
                save()
                loadExercises()
                showAlert = true
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)

            Spacer()
        }
        .padding()
        .navigationTitle("Szczegóły dnia")
        .onAppear {
            self.dayNote = workoutDay.note ?? ""
            loadExercises()
        }
        .alert("Dzień zakończony", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        }
    }

    private func loadExercises() {
        self.exercises = workoutDay.exercises?.allObjects as? [Exercise] ?? []
    }

    private func deleteExercise(at offsets: IndexSet) {
        for index in offsets {
            viewContext.delete(exercises[index])
        }
        save()
        loadExercises()
    }

    private func save() {
        do {
            try viewContext.save()
        } catch {
            print("Błąd zapisu: \(error.localizedDescription)")
        }
    }
}
