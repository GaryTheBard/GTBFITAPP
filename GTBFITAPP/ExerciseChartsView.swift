import SwiftUI
import Charts
import CoreData

struct ExerciseChartsView: View {
    var exercises: [Exercise] // Replace `YourAppNamespace` with the correct namespace

    var body: some View {
        VStack {
            Text("Weight and Reps Over Time")
                .font(.headline)
                .padding(.bottom)

            Chart {
                ForEach(allDatesInRange, id: \.self) { date in
                    let exerciseData = exercises.first(where: { Calendar.current.isDate($0.timestamp ?? Date(), inSameDayAs: date) })
                    let weight = exerciseData?.weight ?? 0
                    let reps = exerciseData?.reps ?? 0
                    
                    BarMark(
                        x: .value("Date", date),
                        y: .value("Weight", weight)
                    )
                    .foregroundStyle(.green)
                    
                    BarMark(
                        x: .value("Date", date),
                        y: .value("Reps", Double(reps))
                    )
                    .foregroundStyle(.purple)
                }
            }
            .chartXAxis {
                AxisMarks(values: allDatesInRange) { value in
                    AxisValueLabel {
                        if let dateValue = value.as(Date.self) {
                            Text(dateFormatter.string(from: dateValue))
                        }
                    }
                }
            }
            .chartYAxisLabel("Weight / Reps")
            .frame(height: 200)
            .padding()
        }
    }

    // Helper function to generate all dates in range
    private var allDatesInRange: [Date] {
        let startDate = Calendar.current.startOfDay(for: exercises.min(by: { $0.timestamp ?? Date() < $1.timestamp ?? Date() })?.timestamp ?? Date())
        let endDate = Calendar.current.startOfDay(for: exercises.max(by: { $0.timestamp ?? Date() < $1.timestamp ?? Date() })?.timestamp ?? Date())
        var dates = [Date]()
        var currentDate = startDate

        while currentDate <= endDate {
            dates.append(currentDate)
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return dates
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
}
