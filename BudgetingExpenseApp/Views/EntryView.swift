//
//  EntryView.swift
//  BudgetingExpenseApp
//
//  Created by Kevin Tzeng on 3/2/24.
//

import Foundation
import SwiftUI
import PhotosUI

struct Entry {
    var name: String
    var price: Double
    var date: Date
    var category: Category
    var image: UIImage?
    
    init(name: String = "", price: Double = 0.0, date: Date = Date(), category: Category = .rent, image: UIImage? = nil) {
        self.name = name
        self.price = price
        self.date = date
        self.category = category
        self.image = image
    }
    
    init(_ builder: (inout Entry) -> Void) {
        self.init()
        builder(&self)
    }

}

//TODO: be able to edit entry view
struct EntryView : View {
    

    var screen : CGRect = UIScreen.main.bounds
    @Environment(\.managedObjectContext) var viewContext
//    @Environment(\.presentationMode) var presentationMode
    @State var isShowingForm : Bool
    @State var entry: Entry = Entry()
    @State var entries : [Expense] = []
    
    var body : some View {
        NavigationStack() {
            List {
                ForEach($entries, id:\.self) { entry in
                    EntrySection(name: entry.name, price:entry.price, image: entry.image, date: entry.date)
                }
                Button {
                    self.isShowingForm.toggle()
                    print(self.isShowingForm)
                } label: {
                    Label("Add Expense", systemImage: "plus.circle")
                        .frame(alignment: .leading)
                }
                .frame(alignment: .center)
                Button(action: {
                    for entry in entries {
                        entry.save(in: viewContext)
                    }
                    entries.removeAll()
                        
                }, label: {
                    Text("Submit All Added Expenses")
                })

            }
            }
        .navigationTitle("Expense Entry")

        .sheet(isPresented: $isShowingForm, content: {
            Form(isShowingForm: $isShowingForm, expenseEntries: $entries, entry: $entry)
        })
    }
    
    func addExpense(name: String, price: Double, category: String, image: UIImage, date: Date) {
        entries.append(Expense(name: name, price: price, date: date, category: category, image: image))
    }
}



struct EntrySection : View {
    @Binding var name : String
    @Binding var price : Double
    @Binding var image : UIImage
    @Binding var date : Date
    var body : some View {
        VStack {
            EntryFirstRow(value1: $name, value2: $price)
            EntrySecondRow(date: date, image: image)
        }
    }
}

struct EntryFirstRow : View {
    @Binding var value1 : String
    @Binding var value2 : Double
    var body: some View {
        HStack{
            Text(value1)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("\(value2, specifier: "%.2f")")
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

struct EntrySecondRow : View {
    @State var date : Date
    @State var image : UIImage
    @State private var photosPickerItem : PhotosPickerItem?
    @State var showingImage : Bool = false
    
    var body: some View {
        HStack {
            Button {
                print("Image")
                showingImage.toggle()
            } label: {
                Label("", systemImage: "paperclip")
            }
            DatePicker(selection: $date, displayedComponents: .date) {
                Text("")
            }.padding(.leading)
        }.sheet(isPresented: $showingImage, content: {
            Image(uiImage: image)
                .resizable()
                .frame(width: 500, height: 500)
        })
    }
}

struct Form : View {
    @Binding var isShowingForm : Bool

    @Binding var expenseEntries : [Expense]
    @Binding var entry: Entry
    @State private var photosPickerItem : PhotosPickerItem?
    @State var hasSelectedImage : Bool = false
    @State var isShowingCamera: Bool = false
    
    var body : some View {
        List {
            Section(header: Text("Name")) {
                TextField("Name", text: $entry.name)
            }
            Section(header: Text("Price")) {
                TextField("Price", value: $entry.price, format: .number)
            }
            Section (header: Text("Image")){
                PhotosPicker(selection: $photosPickerItem) {
                    if self.entry.image == nil {
                        Label("", systemImage: "paperclip")
                    } else {
                        Image(uiImage: self.entry.image!)
                            .resizable()
                            .frame(width: 100, height: 100)
                    }
                }
            }
            Section(header: Text("Date")) {
                DatePicker(selection: $entry.date, displayedComponents: .date) {
                    Text("Date")
                }
            }
            Section(header: Text("Category")) {
                Picker("Category", selection: $entry.category) {
                    ForEach(Category.allCases, id: \.self) { cat in
                        Text(cat.rawValue)
                    }
                }
            }
            Button(action: {
                self.isShowingCamera.toggle()
            }, label: {
                Label("camera", systemImage: "camera")
            })
        }
        .onChange(of: photosPickerItem) { _, _ in
            Task {
                if let photosPickerItem,
                   let data = try? await photosPickerItem.loadTransferable(type: Data.self) {
                    if let pickerImage = UIImage(data: data) {
                        self.entry.image = pickerImage
                    }
                }
                hasSelectedImage.toggle()
            }
        }
        .fullScreenCover(isPresented: self.$isShowingCamera, onDismiss: {
            self.isShowingCamera = false
        }, content: {
            CameraView(entry: $entry)
                .ignoresSafeArea()
        })
        Button(action: {
            self.expenseEntries.append(Expense(name: entry.name, price: entry.price, date: entry.date, category: entry.category.rawValue, image: entry.image!))
            self.isShowingForm.toggle()
        }, label: {
            Text("Done")
        })
        
    }
}


//struct FormPreview : PreviewProvider {
//    static var previews : some View {
//        Form()
//    }
//}
