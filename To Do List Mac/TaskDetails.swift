//
//  TaskDetails.swift
//  To Do List Mac
//
//  Created by Ethan Xu on 2023-11-29.
//

import SwiftUI

struct TaskDetails: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var task: Task
    
    var body: some View {
        Text("Edit Task")
            .font(.title.bold())
            .padding(.top)
        
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
                    ForEach(Priorities.allCases) { priority in
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
            
            if !task.isDeleted {
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
                    
                    if task.haveDueDate {
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
                        .padding(.trailing)
                    }
                }
                .padding()
            }
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

