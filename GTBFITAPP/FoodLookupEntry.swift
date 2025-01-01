import SwiftUI
import CoreData

// The foodLookupEntry struct to define the food items
struct foodLookupEntry: Identifiable {
    var id = UUID()
    var food: String
    var calories: Int16
    var protein: Int16
    var saturatedFat: Int16
    var cholesterol: Int16
    var servingSize: Int16
    var unitOfMeasure: String
}

// Separate screen for the foodLookupEntry functionality
struct FoodTableView: View {
    @Environment(\.managedObjectContext) var managedObjectContext

    // Fetch persisted FoodItem entries from Core Data
    @FetchRequest(
        entity: FoodItem.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \FoodItem.food, ascending: true)]
    ) var foodItems: FetchedResults<FoodItem>
    
    @State private var newFood = ""
    @State private var newCalories: Int16 = 0
    @State private var newProtein: Int16 = 0
    @State private var newSaturatedFat: Int16 = 0
    @State private var newCholesterol: Int16 = 0
    @State private var newServingSize: Int16 = 0
    @State private var newUnitOfMeasure = ""

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Add New Food Item")) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Food:")
                            TextField("Enter food name", text: $newFood)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        VStack(alignment: .leading) {
                            Text("Calories:")
                            TextField("Enter calories", value: $newCalories, formatter: NumberFormatter())
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Protein:")
                            TextField("Enter protein", value: $newProtein, formatter: NumberFormatter())
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        VStack(alignment: .leading) {
                            Text("Sat. Fat:")
                            TextField("Enter saturated fat", value: $newSaturatedFat, formatter: NumberFormatter())
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Cholesterol:")
                            TextField("Enter cholesterol", value: $newCholesterol, formatter: NumberFormatter())
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        VStack(alignment: .leading) {
                            Text("Serv. Size:")
                            TextField("Enter serving size", value: $newServingSize, formatter: NumberFormatter())
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Unit:")
                            TextField("Enter unit of measure", text: $newUnitOfMeasure)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    Button(action: addFoodItem) {
                        Text("Add Item")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()

            TableView(foodItems: foodItems, deleteAction: deleteFoodItems)
        }
        .navigationTitle("Food Items")
    }

    private func addFoodItem() {
        let newItem = FoodItem(context: managedObjectContext)
        newItem.id = UUID()
        newItem.food = newFood
        newItem.calories = newCalories
        newItem.protein = newProtein
        newItem.saturatedFat = newSaturatedFat
        newItem.cholesterol = newCholesterol
        newItem.servingSize = newServingSize
        newItem.unitOfMeasure = newUnitOfMeasure

        do {
            try managedObjectContext.save()
        } catch {
            print("Failed to save food item: \(error)")
        }

        resetForm()
    }

    private func deleteFoodItems(at offsets: IndexSet) {
        for index in offsets {
            let item = foodItems[index]
            managedObjectContext.delete(item)
        }

        do {
            try managedObjectContext.save()
        } catch {
            print("Failed to delete food item: \(error)")
        }
    }

    private func resetForm() {
        newFood = ""
        newCalories = 0
        newProtein = 0
        newSaturatedFat = 0
        newCholesterol = 0
        newServingSize = 0
        newUnitOfMeasure = ""
    }
}

struct TableView: View {
    var foodItems: FetchedResults<FoodItem>
    var deleteAction: (IndexSet) -> Void
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                TableHeader()
            }

            List {
                ForEach(foodItems) { item in
                    TableRow(item: item)
                }
                .onDelete(perform: deleteAction)
            }
        }
    }
}

struct TableHeader: View {
    var body: some View {
        HStack {
            Text("Food").frame(width: 100, alignment: .leading)
            Text("Calories").frame(width: 80, alignment: .leading)
            Text("Protein").frame(width: 80, alignment: .leading)
            Text("Sat. Fat").frame(width: 80, alignment: .leading)
            Text("Cholesterol").frame(width: 100, alignment: .leading)
            Text("Serv. Size").frame(width: 100, alignment: .leading)
            Text("Unit").frame(width: 80, alignment: .leading)
        }
        .padding(.horizontal)
        .font(.headline)
    }
}

struct TableRow: View {
    var item: FoodItem
    
    var body: some View {
        HStack {
            Text(item.food ?? "").frame(width: 100)
            Text("\(item.calories)").frame(width: 80)
            Text("\(item.protein)").frame(width: 80)
            Text("\(item.saturatedFat)").frame(width: 80)
            Text("\(item.cholesterol)").frame(width: 100)
            Text("\(item.servingSize)").frame(width: 100)
            Text(item.unitOfMeasure ?? "").frame(width: 80)
        }
        .padding(.horizontal)
        .font(.subheadline)
    }
}
