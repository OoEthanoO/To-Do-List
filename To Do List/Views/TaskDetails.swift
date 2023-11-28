//
//  TaskDetails.swift
//  To Do List
//
//  Created by Ethan Xu on 2023-11-25.
//

import SwiftUI

struct TaskDetails: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var task: Task
    
    var body: some View {
        Text("Edit Task")
            .font(.title.bold())
        
        List {
            HStack {
                TextField("Enter Task Name Here", text: $task.title)
                    .onChange(of: task.title) {
                        saveChanges()
                    }
            }
            .padding()
            
            HStack {
                Text("Edit Priority")
                
                Spacer()
                
                Label("", systemImage: task.priority == "None" ? "tag" : "tag.fill")
                    .foregroundColor(ContentView().priorityColor(task.priority))

                Picker("", selection: $task.priority) {
                    ForEach(Priorties.allCases) { priority in
                        Text(priority.rawValue)
                            .tag(priority)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: task.priority) {
                    saveChanges()
                }
            }
            .padding()
            
            HStack {
                Text("Mark Complete")
                
                Spacer()
                
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
            }
            .padding()
            
            HStack {
                Toggle("", isOn: $task.haveDueDate)
                    .onChange(of: task.haveDueDate) {
                        saveChanges()
                    }
                    .labelsHidden()
                    .padding(.trailing)
                
                Text("Due Date")
                    .foregroundColor(task.haveDueDate ? .primary : .gray)
                
                Spacer()
                
                DatePicker(
                    "",
                    selection: $task.dueDate,
                    in: Date()...,
                    displayedComponents: [.date]
                )
                .disabled(!task.haveDueDate)
                .onChange(of: task.dueDate) {
                    saveChanges()
                }
            }
            .padding()
        }
    }
    
    private func saveChanges() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving changes: \(error.localizedDescription)")
        }
    }
}

struct TaskDetails_Previews: PreviewProvider {
    static var previews: some View {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        let newTask = Task(context: viewContext)
        newTask.createdAt = Date()
        newTask.priority = "High"
        newTask.isComplete = false
        newTask.dueDate = Date()
        newTask.haveDueDate = true
        
        return TaskDetails(task: newTask)
            .environment(\.managedObjectContext, viewContext)
    }
}
