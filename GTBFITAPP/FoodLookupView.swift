////
////  FoodLookupView.swift
////  GTBFITAPP
////
////  Created by Gary Alfonso on 12/31/24.
////
//
//import SwiftUI
//import CoreData
//
//struct FoodLookupView: View {
//    @Environment(\.managedObjectContext) var managedObjectContext
//    @FetchRequest(
//        entity: FoodItem.entity(),
//        sortDescriptors: [NSSortDescriptor(keyPath: \FoodItem.food, ascending: true)]
//    ) var foodItems: FetchedResults<FoodItem>
//
//    @State private var food = ""
//    @State private var calories: Int16 = 0
//    @State private var protein: Int16 = 0
//    @State private var cholesterol: Int16 = 0
//    @State private var saturatedFat: Int16 = 0
//    @State private var servingSize: Int16 = 0
//    @State private var unitOfMeasure = ""
//
//    var body: some View {
//        VStack {
//            Text("Food Lookup")
//                .font(.largeTitle)
//                .fontWeight(.bold)
//                .padding(.top, 50)
//                .foregroundColor(.blue)
//
//            Divider()
//                .frame(height: 2)
//                .background(Color.black)
//                .padding(.horizontal)
//
//            Form {
//                Section(header: Text("Add New Food Item")) {
//                    TextField("Food", text: $food)
//                    TextField("Calories", value: $calories, formatter: NumberFormatter())
//                        .keyboardType(.numberPad)
//                    TextField("Protein (g)", value: $protein, formatter: NumberFormatter())
//                        .keyboardType(.numberPad)
//                    TextField("Cholesterol (mg)", value: $cholesterol, formatter: NumberFormatter())
//                        .keyboardType(.numberPad)
//                    TextField("Saturated Fat (g)", value: $saturatedFat, formatter: NumberFormatter())
//                        .keyboardType(.numberPad)
//                    TextField("Serving Size", value: $servingSize, formatter: NumberFormatter())
//                        .keyboardType(.numberPad)
//                    TextField("Unit Of Measure", text: $unitOfMeasure)
//
//                    Button(action: saveFoodItem) {
//                        Text("Add Item")
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(Color.blue)
//                            .foregroundColor(.white)
//                            .cornerRadius(10)
//                    }
//                }
//            }
//
//            List {
//                ForEach(foodItems) { item in
//                    HStack {
//                        Text(item.food ?? "Unknown")
//                        Spacer()
//                        Text("\(item.calories) Cal")
//                        Spacer()
//                        Text("\(item.protein) g Protein")
//                    }
//                }
//                .onDelete(perform: deleteFoodItem)
//            }
//        }
//        .navigationBarTitle("Food Lookup", displayMode: .inline)
//    }
//
//    private func saveFoodItem() {
//        let newItem = FoodItem(context: managedObjectContext)
//        newItem.id = UUID()
//        newItem.food = food
//        newItem.calories = calories
//        newItem.protein = protein
//        newItem.cholesterol = cholesterol
//        newItem.saturatedFat = saturatedFat
//        newItem.servingSize = servingSize
//        newItem.unitOfMeasure = unitOfMeasure
//
//        do {
//            try managedObjectContext.save()
//        } catch {
//            print(error.localizedDescription)
//        }
//
//        // Clear fields after saving
//        food = ""
//        calories = 0
//        protein = 0
//        cholesterol = 0
//        saturatedFat = 0
//        servingSize = 0
//        unitOfMeasure = ""
//    }
//
//    private func deleteFoodItem(at offsets: IndexSet) {
//        for index in offsets {
//            let item = foodItems[index]
//            managedObjectContext.delete(item)
//        }
//
//        do {
//            try managedObjectContext.save()
//        } catch {
//            print(error.localizedDescription)
//        }
//    }
//}
//
//struct FoodLookupView_Previews: PreviewProvider {
//    static var previews: some View {
//        FoodLookupView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
//
