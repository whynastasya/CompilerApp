//
//  Lexer.swift
//  Compiler
//
//  Created by nastasya on 30.04.2024.
//

import Foundation

final class Lexer {
    private let sourceCode: [String]
    
    init(sourceCode: String) {
        self.sourceCode = sourceCode.split(separator: "").map { String($0) }
    }
    
    func tokenize() throws -> [Token] {
        var tokens = [Token]()
        
        var i = 0
        while i < sourceCode.count {
            var currentSymbol = sourceCode[i]
            
            if let type = TokenType(rawValue: currentSymbol) {
                tokens.append(Token(string: currentSymbol, type: type, from: i, to: i))
            } else if Language.isAdditiveOperator(currentSymbol) {
                tokens.append(Token(string: currentSymbol, type: .additiveOperators, from: i, to: i))
            } else if Language.isMultiplicativeOperator(currentSymbol) {
                tokens.append(Token(string: currentSymbol, type: .multiplicativeOperators, from: i, to: i))
            } else if Language.isLogicOperator(currentSymbol) && Language.isLogicOperator(sourceCode[i+1]){
                tokens.append(Token(string: currentSymbol+sourceCode[i+1], type: .logicOperators, from: i, to: i+1))
                i += 1
            } else if Language.isNumber(currentSymbol) {
                let number = extractNumber(atStarting: i)
                tokens.append(Token(string: number, type: .integer, from: i, to: i + number.count - 1))
                i += number.count - 1
            } else if Language.isLetter(currentSymbol) {
                let word = extractWord(atStarting: i)
                if Language.isIdentifier(word) {
                    tokens.append(Token(string: word, type: .identifier, from: i, to: i + word.count - 1))
                } else if Language.isKeyword(word) {
                    tokens.append(Token(string: word, type: .init(rawValue: word.lowercased())!, from: i, to: i + word.count - 1))
                } else {
                    tokens.append(Token(string: word, type: .unknown, from: i, to: i + word.count - 1))
                }
                i += word.count - 1
            } else if Language.isEnglish(currentSymbol) {
                throw SyntaxError(description: "Неизвестный символ '\(currentSymbol)'. Используйте русский алфавит", token: Token(string: currentSymbol, type: .unknown, from: i, to: i))
            } else if Language.isSign(currentSymbol) {
                throw SyntaxError(description: "Неизвестный символ '\(currentSymbol)'.", token: Token(string: currentSymbol, type: .unknown, from: i, to: i))
            } else if "89".contains(currentSymbol) {
                throw SyntaxError(description: "Используйте семиричную систему счисления.", token: Token(string: currentSymbol, type: .unknown, from: i, to: i))
            }
            i += 1
        }
        print(tokens)
        tokens.append(Token(string: "", type: .endOfFile, from: i, to: i))
        return tokens
    }
    
    private func extractNumber(atStarting index: Int) -> String {
        var number = sourceCode[index]
        var j = index + 1
        var nextSymbol = j < sourceCode.count ? sourceCode[j] : ""
        while Language.isNumber(nextSymbol) {
            number += nextSymbol
            j += 1
            if j < sourceCode.count {
                nextSymbol = sourceCode[j]
            } else {
                break
            }
        }
        return number
    }
    
    private func extractWord(atStarting index: Int) -> String {
        var word = sourceCode[index]
        var j = index + 1
        var nextSymbol = j < sourceCode.count ? sourceCode[j] : ""
        while Language.isLetter(nextSymbol) || Language.isNumber(nextSymbol) {
            word += nextSymbol
            j += 1
            if j < sourceCode.count {
                nextSymbol = sourceCode[j]
            } else {
                break
            }
        }
        
        return word
    }
}
