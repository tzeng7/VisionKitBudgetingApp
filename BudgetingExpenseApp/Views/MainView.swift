//
//  MainView.swift
//  BudgetingExpenseApp
//
//  Created by Kevin Tzeng on 3/1/24.
//

import Foundation
import SwiftUI

//TODO: setup coredata for the app
//TODO: build initial UI
//TODO: vision kit and implementing camera view 
//TODO: (optional) - fetch request all tiems or sum in predicate
struct MainView : View {
    @Environment(\.managedObjectContext) private var viewContext

    var body : some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            ExpenseStatisticsView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Stats")
                }
        }.onAppear(perform: {
            addItem()
        })
    }
    
    func addItem() {
        print("added item")

    }

}


