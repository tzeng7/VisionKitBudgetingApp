//
//  Expense.swift
//  BudgetingExpenseApp
//
//  Created by Kevin Tzeng on 2/23/24.
//

import Foundation
import UIKit

struct Expense : Hashable {
    var name : String
    var price : Double
    var date : Date
    var category : Category
    var image : UIImage?
    var id: UUID
    
    init(name: String = "", price: Double = 0.0, date: Date = Date(), category: Category = .rent, image: UIImage? = nil, id: UUID = UUID()) {
        self.name = name
        self.price = price
        self.date = date
        self.category = category
        self.image = image
        self.id = id
    }
    
    init(_ builder: (inout Expense) -> Void) {
        self.init()
        builder(&self)
    }
}


