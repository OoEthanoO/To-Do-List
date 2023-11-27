//
//  Priorties.swift
//  To Do List
//
//  Created by Ethan Xu on 2023-11-26.
//

import Foundation

public enum Priorties: String, CaseIterable, Identifiable {
    case none = "None"
    case high = "High"
    case medium = "Medium"
    case low = "Low"
    
    public var id: String { self.rawValue }
}
