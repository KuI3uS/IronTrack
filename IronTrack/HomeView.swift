import SwiftUI
import CoreData
import Charts

struct DailyExerciseStat: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \WorkoutDay.date, ascending: true)],
        animation: .default
    )
    private var allWorkoutDays: FetchedResults<WorkoutDay>

    @State private var selectedDate: Date = Date()

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {

                // 📊 WYKRES PROGRESU
                Text("Progres tygodniowy")
                    .font(.headline)
                    .padding(.horizontal)

                Chart(loadWeeklyStats()) { stat in
                    BarMark(
                        x: .value("Dzień", stat.date.formatted(.dateTime.weekday().locale(Locale(identifier: "pl_PL")))),
                        y: .value("Wykonane", stat.count)
                    )
                }
                .frame(height: 150)
                .padding(.horizontal)

                // 📅 TYDZIEŃ
                Text("Twój tydzień")
                    .font(.title2)
                    .padding(.leading)

                WeekCalendarView(selectedDate: $selectedDate)

                // 📋 Lista dni treningowych
                List {
                    ForEach(filteredWorkoutDays()) { day in
                        NavigationLink {
                            WorkoutDayDetailView(workoutDay: day)
                                .environment(\.managedObjectContext, viewContext)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(day.name ?? "Bez nazwy")
                                    .font(.headline)
                                if let date = day.date {
                                    Text(date.formatted(.dateTime.day().month().year()))
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteWorkoutDay)
                }
            }
            .navigationTitle("IronTrack")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: addWorkoutDay) {
                        Label("Dodaj dzień", systemImage: "plus")
                    }
                }
            }
        }
    }

    // 🔎 Filtrowanie dni dla aktualnie wybranego dnia
    private func filteredWorkoutDays() -> [WorkoutDay] {
        allWorkoutDays.filter { day in
            if let date = day.date {
                return Calendar.current.isDate(date, inSameDayAs: selectedDate)
            }
            return false
        }
    }

    // ➕ Dodaj dzień treningowy
    private func addWorkoutDay() {
        let today = selectedDate

        let alreadyExists = allWorkoutDays.contains { day in
            guard let date = day.date else { return false }
            return Calendar.current.isDate(date, inSameDayAs: today)
        }

        guard !alreadyExists else {
            print("WorkoutDay już istnieje dla wybranego dnia")
            return
        }

        let newDay = WorkoutDay(context: viewContext)
        newDay.date = today
        newDay.name = dayOfWeek(from: today)

        do {
            try viewContext.save()
            print("WorkoutDay zapisany: \(newDay.objectID)")
        } catch {
            print("Błąd zapisu WorkoutDay: \(error.localizedDescription)")
        }
    }

    private func deleteWorkoutDay(at offsets: IndexSet) {
        let days = filteredWorkoutDays()
        for index in offsets {
            viewContext.delete(days[index])
        }
        try? viewContext.save()
    }

    private func dayOfWeek(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pl_PL")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date).capitalized
    }

    // 📊 Wygeneruj dane do wykresu
    private func loadWeeklyStats() -> [DailyExerciseStat] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let week = (0..<7).compactMap { calendar.date(byAdding: .day, value: -$0, to: today) }

        return week.map { day in
            let exercises = allWorkoutDays
                .filter { $0.date != nil && calendar.isDate($0.date!, inSameDayAs: day) }
                .flatMap { ($0.exercises?.allObjects as? [Exercise]) ?? [] }
                .filter { $0.isCompleted }

            return DailyExerciseStat(date: day, count: exercises.count)
        }.reversed()
    }
}
