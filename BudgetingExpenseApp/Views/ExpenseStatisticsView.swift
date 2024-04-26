//
//  ExpenseStatisticsView.swift
//  BudgetingExpenseApp
//
//  Created by Kevin Tzeng on 3/30/24.
//

import Foundation
import SwiftUI
import CoreData

enum DateFilter : String, CaseIterable, Identifiable {
    case day = "day"
    case month = "month"
    case year = "year"
    
    var id: Self { self }
}

struct ExpenseStatisticsView : View {
    
    let helper = HelperMethods()
    
    let oneDay = Calendar.current.date(byAdding: .day, value: -1, to: Date())
    
    @State var expensesPredicate: NSPredicate = NSPredicate(value: true)
    
    @FetchRequest(sortDescriptors: [])
    private var expenses : FetchedResults<ExpenseEntity>
    
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "date > %@", Calendar.current.date(byAdding: .day, value: -1, to: Date())! as NSDate))
    private var expensesDay : FetchedResults<ExpenseEntity>
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \ExpenseEntity.date, ascending: false)], predicate: NSPredicate(format: "date > %@", Calendar.current.date(byAdding: .day, value: -7, to: Date())! as NSDate))
    private var expensesWeek : FetchedResults<ExpenseEntity>
    
    
    @State var dateFilter : DateFilter?
    
    @State var category : Category?
    
    @State private var expensesByDay : [Date : [ExpenseEntity]] = [:]
    
    var body: some View {
            List {
                Section(header: Text("Filters")) {
                    Picker("Category", selection: $category) {
                        Text("None").tag(Optional<Category>.none)
                        ForEach(Category.allCases) { category in
                            Text(category.rawValue).tag(Optional(category))
                        }
                    }
                    Picker("Date", selection: $dateFilter) {
                        Text("None").tag(Optional<DateFilter>.none)
                        ForEach(DateFilter.allCases) { dateFilter in
                            Text(dateFilter.rawValue.capitalized(with: Locale.current)).tag(Optional(dateFilter))
                        }
                    }
                }
                ForEach(expensesByDay.keys.sorted(by: >), id: \.timeIntervalSince1970) { date in
                    Section(header: Text("\(date.formatted(date: .long, time: .omitted))")) {
                        ForEach(expensesByDay[date] ?? []) { expense in
                            HStack {
                                HStack {
                                    Label("", systemImage: Category.from(expense.category!).sfSymbol)
                                    Text(expense.name!)
                                    
                                }.frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text("\(helper.getCurrency())\(expense.price, specifier: "%.2f")")
                                    .frame(alignment: .trailing)
                            }
                        }
                    }
                }
            }
            .onChange(of: dateFilter, updatePredicate)
            .onChange(of: category, updatePredicate)
            .onChange(of: self.expensesPredicate, updateExpenseGrouping)
            .onAppear(perform: updateExpenseGrouping)
    }
    
    private func updateExpenseGrouping() {
        self.expensesByDay = Dictionary(grouping: self.expenses, by: { expense in
            guard let date = expense.date else {
                fatalError("ExpenseEntity.date is non-optional")
            }
            return Calendar.current.startOfDay(for: date)
        })
    }

    private func updatePredicate() {
        self.expensesPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate(for: dateFilter), predicate(for: category)])
        print("Updating predicate => \(String(describing: self.expensesPredicate))")
        self.expenses.nsPredicate = self.expensesPredicate
    }

    private func predicate(for dateFilter: DateFilter?) -> NSPredicate {
        let startDate: Date
        switch dateFilter {
        case .day:
            startDate = Calendar.current.dateInterval(of: .day, for: Date())!.start
        case .month:
            startDate = Calendar.current.dateInterval(of: .month, for: Date())!.start
        case .year:
            startDate = Calendar.current.dateInterval(of: .year, for: Date())!.start
        default:
            return NSPredicate(value: true)
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .full

        print("From \(dateFormatter.string(from: startDate))")
        return NSPredicate(format: "date > %@", startDate as NSDate)
    }
    
    private func predicate(for category: Category?) -> NSPredicate {
        guard let category else {
            return NSPredicate(value: true)
        }
        return NSPredicate(format: "category == %@", category.rawValue)
    }
}
