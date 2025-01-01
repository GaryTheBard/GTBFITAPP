import SwiftUI
import CoreData

struct MainView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State private var totalProtein: Int16 = 0
    @State private var totalCalories: Int16 = 0
    @State private var totalWeightLifted: Double = 0.0 // Changed to Double for precision
    @State private var totalReps: Int = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                // White Background
                Color.white.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 40) {
                    // Title
                    Text("GTB FIT")
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundColor(Color.black)
                        .padding(.top, 50)
                        .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 5)
                    
                    // Daily Quote
                    Text("“The only bad workout is the one that didn’t happen.”")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                    
                    // Divider with Snazzy Style
                    Divider()
                        .frame(height: 3)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.red, Color.blue]), startPoint: .leading, endPoint: .trailing))
                        .padding(.horizontal)
                    
                    // Buttons with Bootstrap Style
                    VStack(spacing: 30) {
                        NavigationLink(destination: LogFoodView().environment(\.managedObjectContext, managedObjectContext)) {
                            HStack {
                                Image(systemName: "fork.knife")
                                    .font(.title)
                                    .foregroundColor(.white)
                                Text("Log Food")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .frame(width: UIScreen.main.bounds.width / 2)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .shadow(color: Color.gray, radius: 5, x: 0, y: 5)
                        }
                        
                        NavigationLink(destination: LogExerciseView().environment(\.managedObjectContext, managedObjectContext)) {
                            HStack {
                                Image(systemName: "figure.walk")
                                    .font(.title)
                                    .foregroundColor(.white)
                                Text("Log Exercise")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .frame(width: UIScreen.main.bounds.width / 2)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .shadow(color: Color.gray, radius: 5, x: 0, y: 5)
                        }
                        
                        NavigationLink(destination: JournalView().environment(\.managedObjectContext, managedObjectContext)) {
                            HStack {
                                Image(systemName: "book")
                                    .font(.title)
                                    .foregroundColor(.white)
                                Text("Journal")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .frame(width: UIScreen.main.bounds.width / 2)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .shadow(color: Color.gray, radius: 5, x: 0, y: 5)
                        }
                        
                        // Navigation link to FoodTableView
                        NavigationLink(destination: FoodTableView()) {
                            HStack {
                                Image(systemName: "list.bullet")
                                    .font(.title)
                                    .foregroundColor(.white)
                                Text("Food Table")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .frame(width: UIScreen.main.bounds.width / 2)
                            .background(Color.green)
                            .cornerRadius(10)
                            .shadow(color: Color.gray, radius: 5, x: 0, y: 5)
                        }
                        
                        // Added Navigation link to ExerciseTableView
                        NavigationLink(destination: ExerciseTableView().environment(\.managedObjectContext, managedObjectContext)) {
                            HStack {
                                Image(systemName: "list.bullet")
                                    .font(.title)
                                    .foregroundColor(.white)
                                Text("Exercise Table")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .frame(width: UIScreen.main.bounds.width / 2)
                            .background(Color.teal)
                            .cornerRadius(10)
                            .shadow(color: Color.gray, radius: 5, x: 0, y: 5)
                        }
                    }
                    
                    Spacer()
                    
                    // Progress Summary
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Today's Summary")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        Text("Total Protein: \(totalProtein) g")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text("Total Calories: \(totalCalories) kcal")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text("Total Weight Lifted: \(String(format: "%.2f", totalWeightLifted)) lbs")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Text("Total Reps: \(totalReps)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    // Custom Image at the Bottom
                    Image("logo")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .padding(.bottom, 30)
                }
                .padding(.horizontal)
                .onAppear(perform: loadDailyTotals)
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Ensure it behaves properly in all contexts
    }
    
    private func loadDailyTotals() {
        let today = Calendar.current.startOfDay(for: Date())
        
        // Fetch FoodItems
        let foodFetchRequest: NSFetchRequest<Food> = Food.fetchRequest()
        foodFetchRequest.predicate = NSPredicate(format: "timestamp >= %@", today as NSDate)
        
        // Fetch ExerciseEntries
        let exerciseFetchRequest: NSFetchRequest<Exercise> = Exercise.fetchRequest()
        exerciseFetchRequest.predicate = NSPredicate(format: "timestamp >= %@", today as NSDate)
        
        do {
            let foodItems = try managedObjectContext.fetch(foodFetchRequest)
            let exerciseEntries = try managedObjectContext.fetch(exerciseFetchRequest)
            
            // Calculate totals
            totalProtein = foodItems.reduce(0) { $0 + $1.protein }
            totalCalories = foodItems.reduce(0) { $0 + $1.calories }
            totalWeightLifted = exerciseEntries.reduce(0.0) { $0 + ($1.weight * Double($1.reps)) }
            totalReps = exerciseEntries.reduce(0) { $0 + Int($1.reps) }
            
        } catch {
            print("Failed to fetch items: \(error)")
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
