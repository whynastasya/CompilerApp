//
//  Token.swift
//  Compiler
//
//  Created by nastasya on 30.04.2024.
//

import Foundation

struct Token {
    var string: String
    var type: TokenType
    var from: Int
    var to: Int
}
