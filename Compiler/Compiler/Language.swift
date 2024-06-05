//
//  Language.swift
//  Compiler
//
//  Created by nastasya on 30.04.2024.
//

import Foundation

final class Language {
    static var letters = "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюя"
    static var english = "QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm"
    static var signs = ",.<>?'@#$%^№;\\{}"
    static var numbers = "01234567"
    static var multiplicativeOperators = ["*", "/"]
    static var logicOperators = ["|", "&"]
    static var additiveOperators = ["+", "-"]
    static var keywords = ["программа", "ввод", "конец"]
    
    static func isNumber(_ char: String) -> Bool {
        numbers.contains(char)
    }
    
    static func isLetter(_ char: String) -> Bool {
        letters.contains(char)
    }
    
    static func isAdditiveOperator(_ char: String) -> Bool {
        additiveOperators.contains(char)
    }
    
    static func isMultiplicativeOperator(_ char: String) -> Bool {
        multiplicativeOperators.contains(char)
    }
    
    static func isLogicOperator(_ char: String) -> Bool {
        logicOperators.contains(char)
    }
    
    static func isIdentifier(_ identifier: String) -> Bool {
        let identifierChars = Array(identifier)
        
        guard identifier.count == 4,
              Language.isLetter(String(identifierChars[0])),
              Language.isNumber(String(identifierChars[1])),
              Language.isNumber(String(identifierChars[2])),
              Language.isNumber(String(identifierChars[3])) else { return false }
        
        return true
    }
    
    static func isKeyword(_ word: String) -> Bool {
        keywords.contains(word.lowercased())
    }
    
    static func isEnglish(_ char: String) -> Bool {
        english.contains(char)
    }
    
    static func isSign(_ char: String) -> Bool {
        signs.contains(char)
    }
}
