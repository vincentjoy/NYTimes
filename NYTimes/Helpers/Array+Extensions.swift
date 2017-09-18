//
//  Array+Extensions.swift
//  NYTimes
//
//  Created by voonik on 31/08/17.
//  Copyright © 2017 NYTimes. All rights reserved.
//

import Foundation

extension Array where Element: Comparable {
    
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted(by:<) == other.sorted(by:<)
    }
}
