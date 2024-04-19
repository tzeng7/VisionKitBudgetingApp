//
//  BudgetingExpenseAppApp.swift
//  BudgetingExpenseApp
//
//  Created by Kevin Tzeng on 2/23/24.
//

import SwiftUI

@main
struct BudgetingExpenseApp: App {
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
