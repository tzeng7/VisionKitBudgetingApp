//
//  ExpenseView.swift
//  BudgetingExpenseApp
//
//  Created by Kevin Tzeng on 3/2/24.
//

import Foundation
import SwiftUI

struct ExpenseView : View {
    @Environment(\.dismiss) private var dismiss
    @Binding var rootIsActive : Bool
    
    var body : some View {
        NavigationStack() {
            // root view here should be EntryView
            
            HStack {
                NavigationLink(destination: EntryView(isShowingForm: false, name: "", price: 0.0, date: Date())) {
                    Label("", systemImage: "square.and.pencil")
                }
                .isDetailLink(false)
                .font(.system(size: 30))
            
                NavigationLink(destination: CameraView()) {
                    Label("", systemImage: "camera")
                }.font(.system(size: 30))
                    .padding(.leading, 10)
            }.frame(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .offset(x: 10, y: 0)
        }
    }
}
//}
//struct ExpenseViewPreview : PreviewProvider {
//    static var previews: some View {
//        ExpenseView()
//    }
//}
