import SwiftUI
import CoreData

struct WorkoutDayDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var workoutDay: WorkoutDay

    @State private var dayNote: String = ""
    @State private var showAlert = false
    @State private var showExerciseSheet = false
    @State private var selectedExerciseForEdit: Exercise?
    @State private var refreshTrigger = UUID()

    @FetchRequest private var exercises: FetchedResults<Exercise>

    init(workoutDay: WorkoutDay) {
        self.workoutDay = workoutDay

        let predicate = NSPredicate(format: "workoutDay == %@", workoutDay)
        _exercises = FetchRequest<Exercise>(
            sortDescriptors: [NSSortDescriptor(keyPath: \Exercise.date, ascending: true)],
            predicate: predicate,
            animation: .default
        )
    }

    var completedCount: Int {
        exercises.filter { $0.isCompleted }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerView
            noteEditorView
            progressView
            addButton
            exerciseListView
            finishDayButton
            Spacer()
        }
        .padding()
        .onAppear {
            dayNote = workoutDay.note ?? ""
        }
        .sheet(isPresented: $showExerciseSheet) {
            ExerciseListView(workoutDay: workoutDay) {
                refreshTrigger = UUID()
            }
            .environment(\.managedObjectContext, viewContext)
        }
        .sheet(item: $selectedExerciseForEdit) { exercise in
            ExerciseEditView(exercise: exercise) {
                refreshTrigger = UUID()
            }
        }
        .alert("Dzień zakończony ✅", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        }
        .navigationTitle("Szczegóły dnia")
    }

    // MARK: - Widoki pomocnicze

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(workoutDay.name ?? "Trening")
                .font(.title)

            if let date = workoutDay.date {
                Text(date.formatted(.dateTime.day().month().year()))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
    }

    private var noteEditorView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notatka")
                .font(.headline)

            TextEditor(text: $dayNote)
                .onChange(of: dayNote) {
                    workoutDay.note = dayNote
                    save()
                }
                .frame(height: 100)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
        }
    }

    private var progressView: some View {
        Text("Wykonane ćwiczenia: \(completedCount)/\(exercises.count)")
            .font(.subheadline)
            .foregroundColor(.secondary)
    }

    private var addButton: some View {
        Button {
            showExerciseSheet = true
        } label: {
            Label("Dodaj ćwiczenie", systemImage: "plus.circle")
        }
    }

    private var exerciseListView: some View {
        Group {
            if exercises.isEmpty {
                Text("Brak ćwiczeń")
                    .foregroundColor(.gray)
                    .italic()
            } else {
                List {
                    ForEach(exercises) { exercise in
                        exerciseRow(for: exercise)
                    }
                    .onDelete(perform: deleteExercise)
                }
                .id(refreshTrigger)
            }
        }
    }

    private func exerciseRow(for exercise: Exercise) -> some View {
        HStack {
            Button {
                exercise.isCompleted.toggle()
                save()
            } label: {
                Image(systemName: exercise.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(exercise.isCompleted ? .green : .gray)
                    .imageScale(.large)
                    .padding(10)

                #if os(iOS)
                    .background(Color(UIColor.systemGray6))
                #endif

                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

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
            .onTapGesture {
                selectedExerciseForEdit = exercise
            }
        }
    }

    private var finishDayButton: some View {
        Button("Zakończ dzień") {
            for ex in exercises {
                ex.isCompleted = true
            }
            save()
            showAlert = true
        }
        .buttonStyle(.borderedProminent)
        .padding(.top)
    }

    private func deleteExercise(at offsets: IndexSet) {
        offsets.map { exercises[$0] }.forEach(viewContext.delete)
        save()
    }

    private func save() {
        do {
            try viewContext.save()
        } catch {
            print("❌ Błąd zapisu: \(error.localizedDescription)")
        }
    }
}
