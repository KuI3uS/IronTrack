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

    var body: some View {
        NavigationStack {
            HomeView()
                .navigationTitle("IronTrack")
        }
    }
}
