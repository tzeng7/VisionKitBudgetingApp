//
//  HomeView.swift
//  BudgetingExpenseApp
//
//  Created by Kevin Tzeng on 2/27/24.
//

import Foundation
import SwiftUI

struct HomeView : View {
    
    @State var path : NavigationPath = NavigationPath()
    
    let screenWidth = UIScreen.main.bounds.size.width
    let screenHeight = UIScreen.main.bounds.size.height
    @State var expenses : FetchedResults<ExpenseEntity>
    @State var total : Double = 0.0
    @State var rent : Double = 0.0
    @State var foodAndDrink : Double = 0.0
    @State var utilities : Double = 0.0
    @State var travel : Double = 0.0
    @State var misc : Double = 0.0
    @State var hasAppeared : Bool = false
    
    var body : some View {
        NavigationStack(path: $path) {
            Text(Date.now, format: .dateTime.month(.wide))
                .fontWeight(.bold)
                .font(.system(size: 50))
                .toolbar {
                    NavigationLink {
                        ExpenseView()
                    } label: {
                        Label("Moved to Expense View", systemImage: "plus")
                    }.isDetailLink(false)
                }
            
            ZStack {
                ProgressCircle(total: $total, rent: $rent, foodAndDrink: $foodAndDrink, utilities: $utilities, travel: $travel, misc: $misc)
                Text("$\(total, specifier: "%.2f")")
                    .font(.system(size: 25))
                    .padding()
            }.position(x: screenWidth / 2, y: screenHeight / 4)
            
            VStack {
                HStack {
                    Text("Rent")
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                        .padding(.leading, 20)
                    Text("\(rent, specifier: "%.2f")")
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .trailing)
                        .padding(.trailing, 20)
                }
                HStack {
                    Text("Food & Drink")
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                        .padding(.leading, 20)
                    Text("\(foodAndDrink, specifier: "%.2f")")
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .trailing)
                        .padding(.trailing, 20)
                }
                HStack {
                    Text("Utilities")
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                        .padding(.leading, 20)
                    Text("\(utilities, specifier: "%.2f")")
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .trailing)
                        .padding(.trailing, 20)
                }
                HStack {
                    Text("Travel")
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                        .padding(.leading, 20)
                    Text("\(travel, specifier: "%.2f")")
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .trailing)
                        .padding(.trailing, 20)
                }
                HStack {
                    Text("Miscellaneous")
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                        .padding(.leading, 20)
                    Text("\(misc, specifier: "%.2f")")
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .trailing)
                        .padding(.trailing, 20)
                }
            }.font(.system(size: 25))
                .position(x: screenWidth/2 ,y: screenHeight/4 - 30)
        }
        .onAppear {
            if !hasAppeared {
                hasAppeared.toggle()
                total = 0
                rent = 0
                foodAndDrink = 0
                utilities = 0
                travel = 0
                misc = 0
                getCategoryTotals()
            }
        }
    }
    
    func getCategoryTotals() {
        for expense in expenses {
            total += expense.price
            switch expense.category {
            case "Rent":
                rent += expense.price
            case "Food & Drink":
                foodAndDrink += expense.price
            case "Utilities":
                utilities += expense.price
            case "Travel":
                travel += expense.price
            case "Miscellaneous":
                misc += expense.price
            default:
                print("none")
            }
        }
    }
    
    struct ProgressCircle : View {
        @Binding var total : Double
        @Binding var rent : Double
        @Binding var foodAndDrink : Double
        @Binding var utilities : Double
        @Binding var travel : Double
        @Binding var misc : Double
        
        var body : some View {
            ZStack {
                Circle()
                    .trim(from: 0.0, to: (misc/total))
                    .stroke(AngularGradient(colors: [Color.white], center: .center, startAngle: .degrees(0), endAngle: .degrees(360)),style: StrokeStyle(lineWidth: 30, lineCap: .butt))                    .rotationEffect(.degrees(-90))
                    .padding([.leading, .trailing], 50)
                Circle()
                    .trim(from: 0.0, to: (rent/total))
                    .stroke(AngularGradient(colors: [Color.blue], center: .center, startAngle: .degrees(0), endAngle: .degrees(360)),style: StrokeStyle(lineWidth: 30, lineCap: .butt))
                    .rotationEffect(.degrees(-90 + (misc/total*360)))
                    .padding([.leading, .trailing], 50)
                Circle()
                    .trim(from: 0.0, to: (foodAndDrink/total))
                    .stroke(AngularGradient(colors: [Color.red], center: .center, startAngle: .degrees(0), endAngle: .degrees(360)),style: StrokeStyle(lineWidth: 30, lineCap:.butt))
                    .rotationEffect(.degrees(-90 + (misc/total*360) + (rent/total*360)))
                    .padding([.leading, .trailing], 50)
                Circle()
                    .trim(from: 0.0, to: (utilities/total))
                    .stroke(AngularGradient(colors: [Color.yellow], center: .center, startAngle: .degrees(0), endAngle: .degrees(360)),style: StrokeStyle(lineWidth: 30, lineCap: .butt))
                    .rotationEffect(.degrees(-90 + (misc/total*360) + (rent/total*360) + (foodAndDrink/total*360)))
                    .padding([.leading, .trailing], 50)
                Circle()
                    .trim(from: 0.0, to: (travel/total))
                    .stroke(AngularGradient(colors: [Color.purple], center: .center, startAngle: .degrees(0), endAngle: .degrees(360)),style: StrokeStyle(lineWidth: 30, lineCap: .butt))
                    .rotationEffect(.degrees(-90 + (misc/total*360) + (rent/total*360) + (foodAndDrink/total*360) + (utilities/total*360)))
                    .padding([.leading, .trailing], 50)
            }
            
        }
        
        
    }
    
//    struct HomeView_Previews : PreviewProvider {
//    
//        static var previews : some View {
//    
//            HomeView(expenses: expenses)
//        }
//    }
//    struct ProgressCircle_Previews : PreviewProvider {
//        static var previews : some View {
//            ProgressCircle(total: <#T##Binding<Double>#>, rent: <#T##Binding<Double>#>, foodAndDrink: <#T##Binding<Double>#>, utilities: <#T##Binding<Double>#>, travel: <#T##Binding<Double>#>, misc: <#T##Binding<Double>#>)
//        }
//    }
}
