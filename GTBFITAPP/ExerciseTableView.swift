import SwiftUI
import CoreData

// The exerciseLookupEntry struct to define the exercise items
struct exerciseLookupEntry: Identifiable {
    var id = UUID()
    var muscleGroup: String
    var exerciseName: String
}

// Separate screen for the exerciseLookupEntry functionality
struct ExerciseTableView: View {
    @Environment(\.managedObjectContext) var managedObjectContext

    // Fetch persisted ExerciseItem entries from Core Data
    @FetchRequest(
        entity: ExerciseItem.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ExerciseItem.muscleGroup, ascending: true)]
    ) var exerciseItems: FetchedResults<ExerciseItem>
    
    @State private var newMuscleGroup = ""
    @State private var newExerciseName = ""

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Add New Exercise Item")) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Muscle Group:")
                            TextField("Enter muscle group", text: $newMuscleGroup)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        VStack(alignment: .leading) {
                            Text("Exercise Name:")
                            TextField("Enter exercise name", text: $newExerciseName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    Button(action: addExerciseItem) {
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

            ExerciseTableViewContent(exerciseItems: exerciseItems, deleteAction: deleteExerciseItems)
        }
        .navigationTitle("Exercise Items")
    }

    private func addExerciseItem() {
        let newItem = ExerciseItem(context: managedObjectContext)
        newItem.id = UUID()
        newItem.muscleGroup = newMuscleGroup
        newItem.exerciseName = newExerciseName

        do {
            try managedObjectContext.save()
        } catch {
            print("Failed to save exercise item: \(error)")
        }

        resetForm()
    }

    private func deleteExerciseItems(at offsets: IndexSet) {
        for index in offsets {
            let item = exerciseItems[index]
            managedObjectContext.delete(item)
        }

        do {
            try managedObjectContext.save()
        } catch {
            print("Failed to delete exercise item: \(error)")
        }
    }

    private func resetForm() {
        newMuscleGroup = ""
        newExerciseName = ""
    }
}

struct ExerciseTableViewContent: View {
    var exerciseItems: FetchedResults<ExerciseItem>
    var deleteAction: (IndexSet) -> Void
    
    var body: some View {
        List {
            ForEach(groupedExerciseItems.keys.sorted(), id: \.self) { muscleGroup in
                DisclosureGroup(muscleGroup) {
                    ForEach(groupedExerciseItems[muscleGroup]!, id: \.self) { item in
                        ExerciseTableRow(item: item)
                    }
                    .onDelete(perform: deleteAction)
                }
            }
        }
    }
    
    private var groupedExerciseItems: [String: [ExerciseItem]] {
        Dictionary(grouping: exerciseItems, by: { $0.muscleGroup ?? "Unknown" })
    }
}

struct ExerciseTableHeader: View {
    var body: some View {
        HStack {
            Text("Muscle Group").frame(width: 150, alignment: .leading)
            Text("Exercise Name").frame(width: 150, alignment: .leading)
        }
        .padding(.horizontal)
        .font(.headline)
    }
}

struct ExerciseTableRow: View {
    var item: ExerciseItem
    
    var body: some View {
        HStack {
            Text(item.muscleGroup ?? "").frame(width: 150)
            Text(item.exerciseName ?? "").frame(width: 150)
        }
        .padding(.horizontal)
        .font(.subheadline)
    }
}
