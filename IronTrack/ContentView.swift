//
//  ContentView.swift
//  IronTrack
//
//  Created by Jakub Marcinkowski on 07/04/2025.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath:\WorkoutDay.name, ascending: true)],
        animation: .default)
    private var days: FetchedResults<WorkoutDay>

    var body: some View {
        NavigationView {
            List {
                ForEach(days) { day in
                    NavigationLink(destination: ExerciseListView(workoutDay: day)) {
                        Text(day.name ?? "Bez nazwy")
                    }
                }
                .onDelete(perform: deleteDays)
            }
            .navigationTitle("Workout days")
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button(action: addDay) {
                        Label("Dodaj dzień", systemImage: "plus")
                    }
                }
            }
            Text("Select an item")
        }
    }

    private func addDay() {
        withAnimation {
            let newDay = WorkoutDay(context: viewContext)
            newDay.name = "Dzień \(Date())"
            newDay.date = Date()

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteDays(offsets: IndexSet) {
        withAnimation {
            offsets.map { days[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
