//
//  ContentView.swift
//  To Do List
//
//  Created by Ethan Xu on 2023-11-25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.createdAt, ascending: true)],
        animation: .default)
    private var tasks: FetchedResults<Task>
    
    @State var newTitle: String = ""

    var body: some View {
        NavigationSplitView {
            HStack {
                TextField("Add a task", text: $newTitle)
                    .onSubmit {
                        addTask()
                    }
                
                Button {
                    addTask()
                } label: {
                    Text("Add")
                }
            }
            .padding()
            
            List {
                ForEach(tasks) { task in
                    NavigationLink {
                        TaskDetails(task: task)
                    } label: {
                        HStack {
                            Button {
                                task.isComplete.toggle()
                            } label: {
                                Label("", systemImage: task.isComplete ? "checkmark.diamond.fill" : "checkmark.diamond")
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            
                            Text(task.title)
                                .strikethrough(task.isComplete)
                                .foregroundColor(task.isComplete ? .gray : .primary)
                            
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
            newTitle = ""

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteTask(_ task: Task) {
        withAnimation {
            viewContext.delete(task)

            do {
                try viewContext.save()
            } catch {
                // Handle error
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
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
