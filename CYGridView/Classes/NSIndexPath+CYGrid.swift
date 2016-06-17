//
//  NSIndexPath+CYGrid.swift
//  Pods
//
//  Created by zhangxi on 2016/6/17.
//
//

import UIKit

public extension NSIndexPath {
    public convenience init(forX x: Int, forY y: Int) {
        self.init(indexes: [x, y], length: 2)
    }
    
    public var x: Int {
        return self.indexAtPosition(0)
    }
    
    public var y: Int {
        return self.indexAtPosition(1)
    }
    
    public convenience init(forColumn column: Int, forRow row: Int) {
        self.init(indexes: [column, row], length: 2)
    }
    
    public var column: Int {
        return self.indexAtPosition(0)
    }
}