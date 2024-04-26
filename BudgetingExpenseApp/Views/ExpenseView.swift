//
//  ExpenseView.swift
//  BudgetingExpenseApp
//
//  Created by Kevin Tzeng on 3/2/24.
//

import Foundation
import SwiftUI

struct ExpenseView : View {
    @Binding var refreshMain : Bool
    var body : some View {
        NavigationStack() {
            EntryView(isShowingForm: false, refreshMain: $refreshMain)
        }
    }
}

//struct ExpenseViewPreview : PreviewProvider {
//    static var previews: some View {
//        ExpenseView(ref)
//    }
//}
