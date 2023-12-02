//
//  Priorities.swift
//  To Do List Mac
//
//  Created by Ethan Xu on 2023-11-29.
//

import Foundation

public enum Priorities: String, CaseIterable, Identifiable {
    case none = "None"
    case high = "High"
    case medium = "Medium"
    case low = "Low"
    
    public var id: String { self.rawValue }
}
