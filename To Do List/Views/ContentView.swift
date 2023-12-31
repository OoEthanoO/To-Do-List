//
//  ContentView.swift
//  To Do List
//
//  Created by Ethan Xu on 2023-11-25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    enum SortOptions: String, CaseIterable, Identifiable {
        case createdAt = "Creation Date"
        case isComplete = "Completion"
        case priority = "Priority"
        case title = "Title"
        case dueDate = "Due Date"
        
        var id: String { self.rawValue }
    }
    
    private func dayOnlyComparator(date1: Date, date2: Date) -> ComparisonResult {
        let calendar = Calendar.current
        let day1 = calendar.startOfDay(for: date1)
        let day2 = calendar.startOfDay(for: date2)
        return calendar.compare(day1, to: day2, toGranularity: .day)
    }
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.title, ascending: true)],
        animation: .default)
    private var tasks: FetchedResults<Task>
    
    var sortedTasks: [Task] {
        tasks.sorted { (task1: Task, task2: Task) -> Bool in
            switch selectedOption {
            case .title:
                return task1.title < task2.title 
            case .createdAt:
                return task1.createdAt ?? Date() < task2.createdAt ?? Date()
            case .isComplete:
                if task1.isComplete && !task2.isComplete {
                    return false
                } else if !task1.isComplete && task2.isComplete {
                    return true
                } else {
                    return task1.createdAt ?? Date() < task2.createdAt ?? Date()
                }
            case .priority:
                if task1.priority == task2.priority {
                    return task1.createdAt ?? Date() < task2.createdAt ?? Date()
                }
                
                if task1.priority == "High" {
                    return true
                }
                
                if task1.priority == "Medium" {
                    if task2.priority != "High" {
                        return true
                    }
                }
                
                if task1.priority == "Low" {
                    if task2.priority != "High" && task2.priority != "Medium" {
                        return true
                    }
                }
                
                return false
            case .dueDate:
                if task1.haveDueDate == false && task2.haveDueDate == false {
                    return (task1.createdAt ?? Date()) < (task2.createdAt ?? Date())
                }
                
                if task1.haveDueDate != task2.haveDueDate {
                    return task1.haveDueDate && !task2.haveDueDate
                }
                
                let dayComparator = dayOnlyComparator(date1: task1.dueDate, date2: task2.dueDate)
                if dayComparator != .orderedSame {
                    return dayComparator == .orderedAscending
                } else {
                    return (task1.createdAt ?? Date()) < (task2.createdAt ?? Date())
                }
            }
        }
    }
    
    var filteredTasks: [Task] {
        guard !filterKeyword.isEmpty else {
            return sortedTasks
        }
        return sortedTasks.filter { $0.title.localizedCaseInsensitiveContains(filterKeyword) == true }
    }
    
    @State var newTitle: String = ""
    @State private var filterKeyword: String = ""
    @State private var appAnimation: Animation? = .default
    @State private var selectedOption: SortOptions = .createdAt
    @State private var newPriority: Priorties = .none
    
    var body: some View {
        NavigationSplitView {
            TextField("Filter by keyword", text: $filterKeyword.animation(appAnimation))
                .padding()
            
            HStack {
                Text("Sort By: ")
                
                Picker("Sort By", selection: $selectedOption.animation(appAnimation)) {
                    ForEach(SortOptions.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            
            List {
                ForEach(filteredTasks) { task in
                    NavigationLink {
                        TaskDetails(task: task)
                    } label: {
                        TaskRow(task: task)
                    }
                }
            }
            HStack {
                TextField("Add a task", text: $newTitle)
                    .onSubmit {
                        addTask()
                    }
                
                Picker("Priority", selection: $newPriority.animation(appAnimation)) {
                    ForEach(Priorties.allCases) { priority in
                        Text(priority.rawValue)
                            .tag(priority)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                if (newPriority == .none) {
                    Label("", systemImage: "tag")
                } else {
                    Label("", systemImage: "tag.fill")
                        .foregroundColor(priorityColor(newPriority))
                }
                
                Button {
                    addTask()
                } label: {
                    Text("Add")
                }
            }
            .padding()
            .navigationTitle("To Do List")
        } detail: {
            Text("Select a Task")
        }
    }

    private func addTask() {
        withAnimation {
            guard !newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return
            }
            let newTask = Task(context: viewContext)
            newTask.createdAt = Date()
            newTask.title = newTitle
            newTask.priority = newPriority.rawValue
            newTask.dueDate = Date()
            newTask.haveDueDate = false
            newTitle = ""

            saveChanges()
        }
    }
    
    public func saveChanges() {
        do {
            try viewContext.save()
        } catch {
            _ = error as NSError
            print("Error saving changes: \(error.localizedDescription)")
        }
    }
    
    private func priorityColor(_ priority: Priorties) -> Color {
        switch priority {
        case .none:
            return .black
        case .high:
            return .red
        case .medium:
            return .yellow
        case .low:
            return .green
        }
    }
    
    public func priorityColor(_ priority: String?) -> Color {
        switch priority {
        case "High":
            return .red
        case "Medium":
            return .yellow
        case "Low":
            return .green
        default:
            return .primary
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
