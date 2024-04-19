//
//  Expense.swift
//  BudgetingExpenseApp
//
//  Created by Kevin Tzeng on 2/23/24.
//

import Foundation
import UIKit

struct Expense : Hashable{
    var name : String
    var price : Double
    var date : Date
    var category : String
    var image : UIImage
    var id: UUID
    
    init(name: String, price: Double, date: Date, category: String, image: UIImage, id: UUID = UUID()) {
        self.name = name
        self.price = price
        self.date = date
        self.category = category
        self.image = image
        self.id = id
    }
}


