import SwiftUI
import CoreData

struct LogExerciseView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(
        entity: Exercise.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Exercise.timestamp, ascending: true)]
    ) var exercises: FetchedResults<Exercise>
    
    @FetchRequest(
        entity: ExerciseItem.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \ExerciseItem.muscleGroup, ascending: true)]
    ) var exerciseItems: FetchedResults<ExerciseItem>

    @State private var muscleGroup = ""
    @State private var exerciseName = ""
    @State private var weight: Double = 0.0
    @State private var reps: Int16 = 0
    @State private var time: Int16 = 0
    @State private var timestamp = Date()
    @State private var showAlert = false

    var body: some View {
        VStack {
            HStack {
                Text("Exercise Log")
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
                Text("Total Weight Lifted: \(totalWeightLifted, specifier: "%.2f") lbs")
                Spacer()
                Text("Total Reps: \(totalReps)")
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
                            Text("Muscle Group")
                            TypeaheadTextField(
                                text: $muscleGroup,
                                items: muscleGroups,
                                onSelect: { selectedText in
                                    muscleGroup = selectedText
                                }
                            )
                        }
                        VStack(alignment: .leading) {
                            Text("Exercise Name")
                            TypeaheadTextField(
                                text: $exerciseName,
                                items: exerciseNames(for: muscleGroup),
                                onSelect: { selectedText in
                                    exerciseName = selectedText
                                }
                            )
                        }
                    }

                    HStack {
                        VStack(alignment: .leading) {
                            Text("Weight (lbs)")
                            TextField("", value: $weight, formatter: NumberFormatter())
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.decimalPad)
                        }
                        VStack(alignment: .leading) {
                            Text("Reps")
                            TextField("", value: $reps, formatter: NumberFormatter())
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                        }
                    }

                    VStack(alignment: .leading) {
                        Text("Time (minutes)")
                        TextField("", value: $time, formatter: NumberFormatter())
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                    }

                    Button(action: checkAndSaveExercise) {
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
                    ForEach(groupedExercises.keys.sorted(), id: \.self) { exerciseName in
                        DisclosureGroup(exerciseName) {
                            ForEach(groupedExercises[exerciseName]!, id: \.self) { exercise in
                                HStack {
                                    Text("\(exercise.timestamp ?? Date(), formatter: dateFormatter)")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text("\(exercise.weight, specifier: "%.2f") lbs")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text("\(exercise.reps)")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Button(action: {
                                        deleteExercise(at: IndexSet([exercises.firstIndex(of: exercise)!]))
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteExercise)
                }
            }
        }
        .navigationBarTitle("Log Exercise", displayMode: .inline)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("New Exercise Item"),
                message: Text("The exercise item '\(exerciseName)' for muscle group '\(muscleGroup)' is not in the lookup list. Would you like to save it for future use?"),
                primaryButton: .default(Text("Yes"), action: saveNewExerciseItem),
                secondaryButton: .cancel(Text("No"), action: saveExercise)
            )
        }
    }

    private var muscleGroups: [String] {
        Set(exerciseItems.map { $0.muscleGroup ?? "" }).sorted()
    }

    private func exerciseNames(for muscleGroup: String) -> [String] {
        exerciseItems.filter { $0.muscleGroup == muscleGroup }.map { $0.exerciseName ?? "" }.sorted()
    }

    private var groupedExercises: [String: [Exercise]] {
        Dictionary(grouping: filteredExercises, by: { $0.exerciseName ?? "Unknown" })
    }

    private var filteredExercises: [Exercise] {
        return exercises.filter { exercise in
            Calendar.current.isDate(exercise.timestamp ?? Date(), inSameDayAs: timestamp)
        }
    }

    private var totalWeightLifted: Double {
        return filteredExercises.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
    }

    private var totalReps: Int {
        return filteredExercises.reduce(0) { $0 + Int($1.reps) }
    }

    private func checkAndSaveExercise() {
        // Check if the exercise item already exists in ExerciseItem
        if !exerciseItems.contains(where: { $0.muscleGroup == muscleGroup && $0.exerciseName == exerciseName }) {
            showAlert = true
        } else {
            saveExercise()
        }
    }

    private func saveNewExerciseItem() {
        let newItem = ExerciseItem(context: managedObjectContext)
        newItem.id = UUID()
        newItem.muscleGroup = muscleGroup
        newItem.exerciseName = exerciseName

        do {
            try managedObjectContext.save()
        } catch {
            print("Failed to save new exercise item: \(error)")
        }

        saveExercise()
    }

    private func saveExercise() {
        let newExercise = Exercise(context: managedObjectContext)
        newExercise.id = UUID()
        newExercise.muscleGroup = muscleGroup
        newExercise.exerciseName = exerciseName
        newExercise.weight = weight
        newExercise.reps = reps
        newExercise.time = time
        newExercise.timestamp = timestamp
        
        do {
            try managedObjectContext.save()
        } catch {
            print(error.localizedDescription)
        }
        
        // Clear specific fields after saving, but retain muscleGroup, exerciseName, weight, and timestamp
        reps = 0
        time = 0
    }

    private func deleteExercise(at offsets: IndexSet) {
        for index in offsets {
            let exercise = exercises[index]
            managedObjectContext.delete(exercise)
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

struct TypeaheadTextField: View {
    @Binding var text: String
    var items: [String]
    var onSelect: (String) -> Void

    @State private var filteredItems: [String] = []

    var body: some View {
        VStack {
            TextField("Select", text: $text)
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
