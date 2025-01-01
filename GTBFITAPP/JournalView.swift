import SwiftUI
import CoreData

// Separate screen for the journal functionality
struct JournalView: View {
    @Environment(\.managedObjectContext) var managedObjectContext

    @FetchRequest(
        entity: JournalEntry.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \JournalEntry.timestamp, ascending: true)]
    ) var journalEntries: FetchedResults<JournalEntry>
    
    @State private var subject = ""
    @State private var content = ""
    @State private var tags = ""
    @State private var timestamp = Date()
    @State private var showAlert = false

    var body: some View {
        VStack {
            HStack {
                Text("Journal")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                Spacer()
                DatePicker("", selection: $timestamp, displayedComponents: .date)
                    .labelsHidden()
            }
            .padding(.top, 50)
            .padding(.horizontal)

            Divider()
                .frame(height: 2)
                .background(Color.black)
                .padding(.horizontal)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("Subject")
                        TextField("Enter subject", text: $subject)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    VStack(alignment: .leading) {
                        Text("Content")
                        TextEditor(text: $content)
                            .frame(height: 200)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                    }

                    VStack(alignment: .leading) {
                        Text("Tags")
                        TextField("Enter tags", text: $tags)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    Button(action: saveJournalEntry) {
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
                Section(header: Text("Journal Entries").font(.headline)) {
                    ForEach(groupedJournalEntries.keys.sorted(), id: \.self) { subject in
                        DisclosureGroup(subject) {
                            ForEach(groupedJournalEntries[subject]!, id: \.self) { entry in
                                VStack(alignment: .leading) {
                                    Text("Date: \(entry.timestamp ?? Date(), formatter: dateFormatter)")
                                    Text("Tags: \(entry.tags ?? "")")
                                    Text("Content:")
                                    Text(entry.content ?? "")
                                        .padding(.leading)
                                }
                                .padding(.vertical, 5)
                            }
                            .onDelete(perform: deleteJournalEntry)
                        }
                    }
                }
            }
        }
        .navigationBarTitle("Journal", displayMode: .inline)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error"),
                message: Text("Please fill in all fields."),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private var groupedJournalEntries: [String: [JournalEntry]] {
        Dictionary(grouping: filteredJournalEntries, by: { $0.subject ?? "Unknown" })
    }

    private var filteredJournalEntries: [JournalEntry] {
        return journalEntries.filter { entry in
            Calendar.current.isDate(entry.timestamp ?? Date(), inSameDayAs: timestamp)
        }
    }

    private func saveJournalEntry() {
        guard !subject.isEmpty, !content.isEmpty, !tags.isEmpty else {
            showAlert = true
            return
        }

        let newEntry = JournalEntry(context: managedObjectContext)
        newEntry.id = UUID()
        newEntry.subject = subject
        newEntry.content = content
        newEntry.tags = tags
        newEntry.timestamp = timestamp

        do {
            try managedObjectContext.save()
        } catch {
            print("Failed to save journal entry: \(error)")
        }

        resetForm()
    }

    private func deleteJournalEntry(at offsets: IndexSet) {
        for index in offsets {
            let entry = journalEntries[index]
            managedObjectContext.delete(entry)
        }

        do {
            try managedObjectContext.save()
        } catch {
            print("Failed to delete journal entry: \(error)")
        }
    }

    private func resetForm() {
        subject = ""
        content = ""
        tags = ""
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }
}
