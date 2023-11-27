//
//  ContentView.swift
//  To Do List
//
//  Created by Ethan Xu on 2023-11-25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    enum SortOptions: String, CaseIterable, Identifiable {
        case createdAt = "Creation Date"
        case isComplete = "Completion"
        case priority = "Priority"
        case title = "Title"
        
        var id: String { self.rawValue }
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
                        HStack {
                            Button {
                                task.isComplete.toggle()
                            } label: {
                                Label("", systemImage: task.isComplete ? "checkmark.diamond.fill" : "checkmark.diamond")
                                    .foregroundColor(task.isComplete ? .green : .blue)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .onChange(of: task.isComplete) {
                                saveChanges()
                            }
                            
                            if task.priority != "None" {
                                Label("", systemImage: "tag.fill")
                                    .frame(width: 10)
                                    .foregroundColor(priorityColor(task.priority))
                                
                            }
                            
                            Text(task.title)
                                .strikethrough(task.isComplete)
                                .foregroundColor(task.isComplete ? .gray : priorityColor(task.priority))
                            
                            Spacer()
                            
                            Button {
                                deleteTask(task)
                            } label: {
                                Label("", systemImage: "trash.fill")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            TextField("Filter by keyword", text: $filterKeyword.animation(appAnimation))
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
            newTitle = ""

            saveChanges()
        }
    }

    private func deleteTask(_ task: Task) {
        withAnimation {
            viewContext.delete(task)
            saveChanges()
        }
    }
    
    private func saveChanges() {
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

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
