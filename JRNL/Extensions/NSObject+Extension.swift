//
//  NSObject+Extension.swift
//  JRNL
//
//  Created by Vinh Nguyen on 24/04/2024.
//

import Foundation

extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
}
