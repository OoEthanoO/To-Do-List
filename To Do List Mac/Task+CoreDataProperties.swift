//
//  Task+CoreDataProperties.swift
//  To Do List Mac
//
//  Created by Ethan Xu on 2023-11-29.
//

import Foundation
import CoreData


extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var isComplete: Bool
    @NSManaged public var title: String
    @NSManaged public var priority: String
    @NSManaged public var dueDate: Date
    @NSManaged public var haveDueDate: Bool
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.dueDate = Date()
    }
}

extension Task : Identifiable {

}
