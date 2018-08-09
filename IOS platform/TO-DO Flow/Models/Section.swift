//
//  Section.swift
//  TO-DO Flow
//
//  Created by Dai Long on 8/10/18.
//  Copyright © 2018 Dai Long. All rights reserved.
//

import Foundation


class Section {
    var name: String
    var tasks: [Task] = []
    
    init(_ name: String) {
        self.name = name
    }
}
