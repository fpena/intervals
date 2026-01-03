//
//  Item.swift
//  Intervals
//
//  Created by Felipe Pena on 2025-12-13.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
