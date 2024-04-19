//
//  ExpenseView.swift
//  BudgetingExpenseApp
//
//  Created by Kevin Tzeng on 3/2/24.
//

import Foundation
import SwiftUI

struct ExpenseView : View {
    
    var body : some View {
        NavigationStack() {
            EntryView(isShowingForm: false)
        }
    }
}

struct ExpenseViewPreview : PreviewProvider {
    static var previews: some View {
        ExpenseView()
    }
}
