//
//  IronTrackApp.swift
//  IronTrack
//
//  Created by Jakub Marcinkowski on 07/04/2025.
//

import SwiftUI

@main
struct IronTrackApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            NavigationStack {  // ⬅️ OTO TU!
                HomeView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
    }
}
