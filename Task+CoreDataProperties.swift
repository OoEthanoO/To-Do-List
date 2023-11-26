//
//  Task+CoreDataProperties.swift
//  To Do List
//
//  Created by Ethan Xu on 2023-11-25.
//
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

}

extension Task : Identifiable {

}
