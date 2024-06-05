//
//  TokenType.swift
//  Compiler
//
//  Created by nastasya on 30.04.2024.
//

import Foundation

enum TokenType: String {
    case keywordProgram = "программа"
    case keywordEnd = "конец"
    case keywordInput = "ввод"
    case identifier
    case colon = ":"
    case equals = "="
    case additiveOperators
    case multiplicativeOperators
    case logicOperators
    case reverseLogicOperator = "!"
    case openParenthesis = "("
    case closeParenthesis = ")"
    case openSquareBracket = "["
    case closeSquareBracket = "]"
    case integer
    case newLine = "\n"
    case unknown
    case endOfFile
}
