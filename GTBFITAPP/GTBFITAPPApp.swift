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
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
