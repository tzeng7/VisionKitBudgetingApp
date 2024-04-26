//
//  HelperMethods.swift
//  BudgetingExpenseApp
//
//  Created by Kevin Tzeng on 3/1/24.
//
import SwiftUI

struct HelperMethods {
    let locale = Locale.current
    func getCurrency() -> String {
        return locale.currencySymbol!
    }
}
