//
//  CoreDataModels.swift
//  BudgetingExpenseApp
//
//  Created by Kevin Tzeng on 3/28/24.
//

import Foundation
import CoreData

extension Expense {
    func save(in context: NSManagedObjectContext) {
        let item = ExpenseEntity(context: context)
        item.price = price
        item.date = date
        item.name = name
        item.category = category
        item.id = id
        do {
            try context.save()
        } catch {
            fatalError("Problem saving to do item")
        }
    }
}
