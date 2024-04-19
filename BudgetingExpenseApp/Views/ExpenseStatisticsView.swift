//
//  ExpenseStatisticsView.swift
//  BudgetingExpenseApp
//
//  Created by Kevin Tzeng on 3/30/24.
//

import Foundation
import SwiftUI
import CoreData

struct ExpenseStatisticsView : View {
    let systemImageMap = 
    ["Rent": "house",
        "Food & Drink": "fork.knife",
        "Utilities": "lightbulb",
        "Travel" : "airplane.circle",
        "Miscellaneous": "person"]
    
    let oneDay = Calendar.current.date(byAdding: .day, value: -1, to: Date())
    
    @FetchRequest(sortDescriptors: [])
    private var expenses : FetchedResults<ExpenseEntity>
    
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "date > %@", Calendar.current.date(byAdding: .day, value: -1, to: Date())! as NSDate))
    private var expensesDay : FetchedResults<ExpenseEntity>
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \ExpenseEntity.date, ascending: false)], predicate: NSPredicate(format: "date > %@", Calendar.current.date(byAdding: .day, value: -7, to: Date())! as NSDate))
    private var expensesWeek : FetchedResults<ExpenseEntity>
    
    @State var expensesByDay : [Date : [ExpenseEntity]] = [:]
        
    var body: some View {
            List {
                ForEach(expensesByDay.keys.sorted(by: >), id: \.timeIntervalSince1970) { date in
                    Section(header: Text("\(date.formatted(date: .long, time: .omitted))")) {
                        ForEach(expensesByDay[date] ?? []) { expense in
                            HStack {
                                HStack {
                                    Label("", systemImage: systemImageMap[expense.category!]!)
                                    Text(expense.name!)
                                }.frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text("$\(expense.price, specifier: "%.2f")")
                                    .frame(alignment: .trailing)
                            }
                        }
                    }
                }
            }
//        }
        .onAppear {
            self.expensesByDay = Dictionary(grouping: self.expenses, by: { expense in
                guard let date = expense.date else {
                    fatalError("ExpenseEntity.date is non-optional")
                }
                return Calendar.current.startOfDay(for: date)
            })
        }
    }
}
