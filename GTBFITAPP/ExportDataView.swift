import SwiftUI
import CoreData

struct ExportDataView: View {
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
    @State private var exportAllData = true
    @State private var startDate = Date()
    @State private var endDate = Date()

    var body: some View {
        VStack {
            Text("Export Data to CSV")
                .font(.largeTitle)
                .padding(.top, 50)

            Picker(selection: $selectedDataType, label: Text("Data Type")) {
                Text("Food").tag(0)
                Text("Exercise").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            Toggle(isOn: $exportAllData) {
                Text("Export All Data")
            }
            .padding()

            if !exportAllData {
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    .padding()
                DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                    .padding()
            }

            Button(action: exportToCSV) {
                Text("Export")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Export Data")
    }

    private func exportToCSV() {
        let fileName = selectedDataType == 0 ? "FoodLog.csv" : "ExerciseLog.csv"
        guard let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName) else {
            print("Failed to create file path")
            return
        }
        
        var csvText = selectedDataType == 0 ? "Date,Food,Calories,Protein,Cholesterol,Saturated Fat,Serving Size,Unit Of Measure,Comments\n" : "Date,Muscle Group,Exercise Name,Weight,Reps,Time\n"

        if selectedDataType == 0 {
            // Export Food Data
            let filteredFoods = exportAllData ? Array(foods) : Array(foods.filter { $0.timestamp ?? Date() >= startDate && $0.timestamp ?? Date() <= endDate })
            for food in filteredFoods {
                let newLine = "\(food.timestamp ?? Date()),\(food.food ?? ""),\(food.calories),\(food.protein),\(food.cholesterol),\(food.saturatedFat),\(food.servingSize),\(food.unitOfMeasure ?? ""),\(food.comments ?? "")\n"
                csvText.append(newLine)
            }
        } else {
            // Export Exercise Data
            let filteredExercises = exportAllData ? Array(exercises) : Array(exercises.filter { $0.timestamp ?? Date() >= startDate && $0.timestamp ?? Date() <= endDate })
            for exercise in filteredExercises {
                let newLine = "\(exercise.timestamp ?? Date()),\(exercise.muscleGroup ?? ""),\(exercise.exerciseName ?? ""),\(exercise.weight),\(exercise.reps),\(exercise.time)\n"
                csvText.append(newLine)
            }
        }

        do {
            try csvText.write(to: path, atomically: true, encoding: .utf8)
            print("CSV file saved to: \(path)")
            DispatchQueue.main.async {
                let activityView = UIActivityViewController(activityItems: [path], applicationActivities: nil)
                if let topVC = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController {
                    if let popoverController = activityView.popoverPresentationController {
                        popoverController.sourceView = topVC.view
                        popoverController.sourceRect = CGRect(x: topVC.view.bounds.midX, y: topVC.view.bounds.midY, width: 0, height: 0)
                        popoverController.permittedArrowDirections = []
                    }
                    topVC.present(activityView, animated: true, completion: nil)
                }
            }
        } catch let error as NSError {
            print("Failed to write CSV file: \(error.localizedDescription)")
            print("Error details: \(error)")
        } catch {
            print("An unexpected error occurred: \(error)")
        }
    }
}
