//
//  GTBFITAPPApp.swift
//  GTBFITAPP
//
//  Created by Gary Alfonso on 12/31/24.
//

import SwiftUI

@main
struct GTBFITAPPApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
