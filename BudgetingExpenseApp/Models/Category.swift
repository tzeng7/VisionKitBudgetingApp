//
//  Category.swift
//  BudgetingExpenseApp
//
//  Created by Kevin Tzeng on 3/1/24.
//

import Foundation

enum Category : String, CaseIterable, Identifiable {
    
    case rent = "Rent"
    case fooddrink = "Food & Drink"
    case utilities = "Utilities"
    case travel = "Travel"
    case miscellaneous = "Miscellaneous"
    
    var id: Self { self }

    static func from(_ str: String) -> Category {
        return Self.init(rawValue: str) ?? .miscellaneous
    }
    
    var sfSymbol: String {
        switch self {
        case .rent:
            return "house"
        case .fooddrink:
            return "fork.knife"
        case .utilities:
            return "lightbulb"
        case .travel:
            return "airplane.circle"
        case .miscellaneous:
            return "person"
        }
    }
}
