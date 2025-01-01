import SwiftUI
import Charts

struct AnalyticsView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(
        entity: Food.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Food.timestamp, ascending: true)]
    ) var foods: FetchedResults<Food>
    
    @FetchRequest(
        entity: Exercise.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Exercise.timestamp, ascending: true)]
    ) var exercises: FetchedResults<Exercise>
    
    @State private var selectedDataType = 0
    @State private var startDate = Date()
    @State private var endDate = Date()

    var body: some View {
        VStack {
            Text("Analytics")
                .font(.largeTitle)
                .padding(.top, 50)
            
            Picker(selection: $selectedDataType, label: Text("Data Type")) {
                Text("Food").tag(0)
                Text("Exercise").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                .padding()
            DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                .padding()
            
            ScrollView {
                if selectedDataType == 0 {
                    FoodChartsView(foods: filteredFoods)
                } else {
                    ExerciseChartsView(exercises: filteredExercises)
                }
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Analytics")
    }
    
    private var filteredFoods: [Food] {
        foods.filter { $0.timestamp ?? Date() >= startDate && $0.timestamp ?? Date() <= endDate }
    }

    private var filteredExercises: [Exercise] {
        exercises.filter { $0.timestamp ?? Date() >= startDate && $0.timestamp ?? Date() <= endDate }
    }
}
