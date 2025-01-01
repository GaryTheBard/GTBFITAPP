import SwiftUI
import Charts

struct FoodChartsView: View {
    var foods: [Food]

    var body: some View {
        VStack {
            Text("Calories Over Time")
                .font(.headline)
                .padding(.bottom)

            // Calories Chart
            Chart {
                ForEach(allDatesInRangeAdjusted, id: \.self) { date in
                    let data = groupedFoodData[date] ?? (calories: 0, protein: 0)
                    
                    LineMark(
                        x: .value("Date", date),
                        y: .value("Calories", data.calories)
                    )
                    .foregroundStyle(.red)
                    
                    // Average Line for Calories
                    RuleMark(
                        y: .value("Average Calories", averageCalories)
                    )
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                    .foregroundStyle(.red.opacity(0.5))
                }
            }
            .chartXAxis {
                AxisMarks(values: allDatesInRangeAdjusted) { value in
                    AxisValueLabel {
                        if let dateValue = value.as(Date.self) {
                            Text(dateFormatter.string(from: dateValue))
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisValueLabel()
                }
            }
            .chartYScale(domain: 0...maxCalories)
            .chartYAxisLabel("Calories")
            .frame(height: 200)
            .padding()

            Text("Protein Over Time")
                .font(.headline)
                .padding(.bottom)

            // Protein Chart
            Chart {
                ForEach(allDatesInRangeAdjusted, id: \.self) { date in
                    let data = groupedFoodData[date] ?? (calories: 0, protein: 0)
                    
                    LineMark(
                        x: .value("Date", date),
                        y: .value("Protein", data.protein)
                    )
                    .foregroundStyle(.blue)
                    
                    // Average Line for Protein
                    RuleMark(
                        y: .value("Average Protein", averageProtein)
                    )
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                    .foregroundStyle(.blue.opacity(0.5))
                }
            }
            .chartXAxis {
                AxisMarks(values: allDatesInRangeAdjusted) { value in
                    AxisValueLabel {
                        if let dateValue = value.as(Date.self) {
                            Text(dateFormatter.string(from: dateValue))
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisValueLabel()
                }
            }
            .chartYScale(domain: 0...maxProtein)
            .chartYAxisLabel("Protein")
            .frame(height: 200)
            .padding()
            
            VStack(alignment: .leading) {
                ForEach(groupedFoodData.keys.sorted(), id: \.self) { date in
                    let data = groupedFoodData[date] ?? (calories: 0, protein: 0)
                    Text("\(dateFormatter.string(from: date)) - Calories: \(data.calories), Protein: \(data.protein)")
                        .font(.subheadline)
                        .padding(.vertical, 2)
                }
            }
            .padding()
        }
    }
    
    private var groupedFoodData: [Date: (calories: Int, protein: Int)] {
        var groupedData = [Date: (calories: Int, protein: Int)]()
        for food in foods {
            let date = Calendar.current.startOfDay(for: food.timestamp ?? Date())
            if groupedData[date] == nil {
                groupedData[date] = (0, 0)
            }
            groupedData[date]!.calories += Int(food.calories)
            groupedData[date]!.protein += Int(food.protein)
        }
        return groupedData
    }

    // Helper function to generate all dates in range and adjust date alignment
    private var allDatesInRangeAdjusted: [Date] {
        let startDate = Calendar.current.startOfDay(for: foods.min(by: { $0.timestamp ?? Date() < $1.timestamp ?? Date() })?.timestamp ?? Date())
        let endDate = Calendar.current.startOfDay(for: foods.max(by: { $0.timestamp ?? Date() < $1.timestamp ?? Date() })?.timestamp ?? Date())
        var dates = [Date]()
        var currentDate = Calendar.current.date(byAdding: .day, value: -1, to: startDate)!

        while currentDate <= endDate {
            dates.append(currentDate)
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return dates
    }

    private var maxCalories: Int {
        groupedFoodData.values.map { $0.calories }.max() ?? 0
    }

    private var maxProtein: Int {
        groupedFoodData.values.map { $0.protein }.max() ?? 0
    }

    private var averageCalories: Double {
        let totalCalories = foods.reduce(0) { $0 + Int($1.calories) }
        return Double(totalCalories) / Double(foods.count)
    }

    private var averageProtein: Double {
        let totalProtein = foods.reduce(0) { $0 + Int($1.protein) }
        return Double(totalProtein) / Double(foods.count)
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
}
