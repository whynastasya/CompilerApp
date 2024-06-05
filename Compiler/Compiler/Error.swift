//
//  Error.swift
//  Compiler
//
//  Created by nastasya on 01.05.2024.
//

import Foundation

class SyntaxError: Error {
    var description: String
    var token: Token
    
    init(description: String, token: Token) {
        self.description = description
        self.token = token
    }
}

