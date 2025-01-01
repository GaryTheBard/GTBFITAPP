import SwiftUI
import CoreData

struct LogFoodView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(
        entity: Food.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Food.timestamp, ascending: true)]
    ) var foods: FetchedResults<Food>

    @FetchRequest(
        entity: FoodItem.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \FoodItem.food, ascending: true)]
    ) var foodItems: FetchedResults<FoodItem>
    
    @State private var selectedFood: FoodItem?
    @State private var food = ""
    @State private var unitOfMeasure = ""
    @State private var calories: Int16 = 0
    @State private var protein: Int16 = 0
    @State private var cholesterol: Int16 = 0
    @State private var saturatedFat: Int16 = 0
    @State private var servingSize: Int16 = 0
    @State private var comments = ""
    @State private var timestamp = Date()
    @State private var showAlert = false

    var body: some View {
        VStack {
            HStack {
                Text("Food Log")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                Spacer()
                DatePicker("", selection: $timestamp, displayedComponents: .date)
                    .labelsHidden()
            }
            .padding(.top, 50)
            .padding(.horizontal)

            HStack {
                Text("Total Calories: \(totalCalories)")
                Spacer()
                Text("Total Protein: \(totalProtein) g")
            }
            .font(.headline)
            .padding(.horizontal)
            .padding(.bottom, 10)

            Divider()
                .frame(height: 2)
                .background(Color.black)
                .padding(.horizontal)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Food")
                            AutocompleteTextField(
                                text: $food,
                                items: foodItems.map { $0.food ?? "" },
                                onSelect: { selectedText in
                                    if let selectedItem = foodItems.first(where: { $0.food == selectedText }) {
                                        selectedFood = selectedItem
                                        calories = selectedItem.calories
                                        protein = selectedItem.protein
                                        cholesterol = selectedItem.cholesterol
                                        saturatedFat = selectedItem.saturatedFat
                                        servingSize = selectedItem.servingSize
                                        unitOfMeasure = selectedItem.unitOfMeasure ?? ""
                                        food = selectedText
                                    }
                                }
                            )
                        }
                        VStack(alignment: .leading) {
                            Text("Calories")
                            TextField("", value: $calories, formatter: NumberFormatter())
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                    }

                    HStack {
                        VStack(alignment: .leading) {
                            Text("Protein (g)")
                            TextField("", value: $protein, formatter: NumberFormatter())
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                        VStack(alignment: .leading) {
                            Text("Cholesterol (mg)")
                            TextField("", value: $cholesterol, formatter: NumberFormatter())
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                    }

                    HStack {
                        VStack(alignment: .leading) {
                            Text("Saturated Fat (g)")
                            TextField("", value: $saturatedFat, formatter: NumberFormatter())
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                        VStack(alignment: .leading) {
                            Text("Serving Size")
                            TextField("", value: $servingSize, formatter: NumberFormatter())
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                    }

                    HStack {
                        VStack(alignment: .leading) {
                            Text("Unit Of Measure")
                            TextField("", text: $unitOfMeasure)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        VStack(alignment: .leading) {
                            Text("Comments")
                            TextField("", text: $comments)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }

                    Button(action: checkAndSaveFood) {
                        Text("Add Entry")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
            .padding(.bottom, 20)

            List {
                Section(header: Text("Logged Entries").font(.headline)) {
                    HStack {
                        Text("Food").frame(maxWidth: .infinity, alignment: .leading)
                        Text("Date").frame(maxWidth: .infinity, alignment: .leading)
                        Text("Calories").frame(maxWidth: .infinity, alignment: .leading)
                        Text("Protein (g)")
                    }
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    
                    ForEach(filteredFoods) { food in
                        HStack {
                            Text(food.food ?? "Unknown") .frame(maxWidth: .infinity, alignment: .leading)
                            Text("\(food.timestamp ?? Date(), formatter: dateFormatter)") .frame(maxWidth: .infinity, alignment: .leading)
                            Text("\(food.calories)") .frame(maxWidth: .infinity, alignment: .leading)
                            Text("\(food.protein)")
                        }
                    }
                    .onDelete(perform: deleteFood)
                }
            }
        }
        .navigationBarTitle("Log Food", displayMode: .inline)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("New Food Item"),
                message: Text("The food item '\(food)' is not in the lookup list. Would you like to save it for future use?"),
                primaryButton: .default(Text("Yes"), action: saveNewFoodItem),
                secondaryButton: .default(Text("No"), action: saveFood)
            )
        }
    }

    private var filteredFoods: [Food] {
        return foods.filter { food in
            Calendar.current.isDate(food.timestamp ?? Date(), inSameDayAs: timestamp)
        }
    }

    private var totalCalories: Int {
        return filteredFoods.reduce(0) { $0 + Int($1.calories) }
    }

    private var totalProtein: Int {
        return filteredFoods.reduce(0) { $0 + Int($1.protein) }
    }

    private func checkAndSaveFood() {
        // Check if the food item already exists in FoodItem
        if !foodItems.contains(where: { $0.food == food }) {
            showAlert = true
        } else {
            saveFood()
        }
    }

    private func saveNewFoodItem() {
        // Create a new FoodItem entry
        let newItem = FoodItem(context: managedObjectContext)
        newItem.id = UUID()
        newItem.food = food
        newItem.calories = calories
        newItem.protein = protein
        newItem.cholesterol = cholesterol
        newItem.saturatedFat = saturatedFat
        newItem.servingSize = servingSize
        newItem.unitOfMeasure = unitOfMeasure

        saveFood()
    }

    private func saveFood() {
        // Save the food log entry
        let newFood = Food(context: managedObjectContext)
        newFood.id = UUID()
        newFood.food = food
        newFood.unitOfMeasure = unitOfMeasure
        newFood.calories = calories
        newFood.protein = protein
        newFood.cholesterol = cholesterol
        newFood.saturatedFat = saturatedFat
        newFood.servingSize = servingSize
        newFood.comments = comments
        newFood.timestamp = timestamp
        
        do {
            try managedObjectContext.save()
        } catch {
            print(error.localizedDescription)
        }
        
        // Clear fields after saving
        food = ""
        unitOfMeasure = ""
        calories = 0
        protein = 0
        cholesterol = 0
        saturatedFat = 0
        servingSize = 0
        comments = ""
        timestamp = Date()
    }

    private func deleteFood(at offsets: IndexSet) {
        for index in offsets {
            let food = foods[index]
            managedObjectContext.delete(food)
        }
        
        do {
            try managedObjectContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }
}

struct AutocompleteTextField: View {
    @Binding var text: String
    var items: [String]
    var onSelect: (String) -> Void

    @State private var filteredItems: [String] = []

    var body: some View {
        VStack {
            TextField("Select Food", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: text) { newValue in
                    filteredItems = items.filter { $0.lowercased().contains(newValue.lowercased()) }
                }

            if !filteredItems.isEmpty && text != "" {
                List(filteredItems, id: \.self) { item in
                    Text(item)
                        .onTapGesture {
                            text = item
                            onSelect(item)
                            filteredItems.removeAll()
                        }
                }
                .listStyle(PlainListStyle())
                .frame(height: min(200, CGFloat(filteredItems.count) * 44))
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 10)
                .onDisappear { UITableView.appearance().backgroundColor = .clear }
            }
        }
    }
}
