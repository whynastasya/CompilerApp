//
//  Parser.swift
//  Compiler
//
//  Created by nastasya on 01.05.2024.
//

import Foundation

final class Parser {
    private var tokens: [Token]
    private var current: Int = 0
    
    init(tokens: [Token]) {
        self.tokens = tokens
    }
    
    func parseProgram() throws -> Program {
        var program = Program(body: [])
        try expect(.keywordProgram, errorDescription: "Программа должна начинаться со слова 'Программа'")
        let links = try parseLinks()
        if links.body.isEmpty {
            throw SyntaxError(description: "В программе должно быть хотя бы одно звено", token: peek())
        }
        program.body.append(links)
        current -= 1
        try expectNewStatement("Конец программы должен быть на новой строке")
        try expect(.keywordEnd, errorDescription: "Программа должна заканчиваться словом 'Конец'")
        try expect(.endOfFile, errorDescription: "После слова 'Конец' не может быть символов")
    
        return program
    }
    
    private func parseLinks() throws -> Links {
        var links = Links(body: [])
        
        while !check(.keywordEnd) && !isEmpty() {
            // Adjust the new line expectation here
            if !links.body.isEmpty {
                current -= 1
                try expectNewStatement("Ожидается новая строка перед звеном")
            }
            skipNewLine()
            let link = try parseLink()
            links.body.append(link)
        }
        
        return links
    }
    
    private func parseLink() throws -> SingleLink {
        var link = SingleLink(body: [])
        try expect(.keywordInput, errorDescription: "Ожидается ключевое слово 'Ввод'")
        try expectNewStatement("Ожидается новая строка после 'Ввод'")
        
        while !check(.keywordEnd) && !isEmpty() && !check(.keywordInput) {
            let word = try parseWord()
            link.body.append(word)
            skipNewLine()
        }
        return link
    }
    
    private func parseWord() throws -> Word {
        try expect(.integer, errorDescription: "Слово начинается с целочисленной метки")
        try expect(.colon, errorDescription: "После oбъявления метки должно стоять двоеточие ':'")
        let identifier = try expect(.identifier, errorDescription: "После метки и двоеточия должна стоять переменная, состоящая из буквы и 3 цифр. Например, A123")
        try expect(.equals, errorDescription: "После объявления переменной должен стоять знак равно '='")
        
        if check(.newLine) {
            throw SyntaxError(description: "Правая часть выражения не может быть пустой", token: peek())
        }
        
        let rhs = try parseAdditionBlock()
        var word = Word(identifier: identifier, rhs: rhs)
        
        return word
    }
    
    private func parseAdditionBlock(squareBracketDepth: Int = 0) throws -> Expression {
        var unaryOperation: Token? = nil
        
        if peek().string == "-" {
            unaryOperation = peek()
        }
        
        var expression = try parseMultiplicationBlock(squareBracketDepth: squareBracketDepth)
        if let operation = unaryOperation {
            expression = UnaryExpression(operator: operation, innerExpression: expression)
        }
        
        while check(.additiveOperators) {
            let binaryOperator = try expect(.additiveOperators, errorDescription: "Ожидается бинарный оператор '+' или '-'")
            let rhs = try parseMultiplicationBlock(squareBracketDepth: squareBracketDepth)
            expression = BinaryExpression(lhs: expression, operator: binaryOperator, rhs: rhs)
        }
        while check(.unknown) {
                throw SyntaxError(description: "В выражении могут быть только переменные, целые числа и выражения в скобках (круглых с любой глубиной вложенности и квадратных с глубиной вложенности 2)", token: peek())
        }
        
        if check(.newLine) || check(.keywordEnd) || isEmpty() {
            if tokens[current - 1].type == .additiveOperators {
                throw SyntaxError(description: "После оператора должно идти цифра или переменная", token: tokens[current - 1])
            }
        }

        return expression
    }
    
    private func parseMultiplicationBlock(squareBracketDepth: Int = 0) throws -> Expression {
        var expression = try parseLogicBlock(squareBracketDepth: squareBracketDepth)
        
        while check(.multiplicativeOperators) {
            let multiplicativeOperator = try expect(.multiplicativeOperators, errorDescription: "Ожидается бинарный оператор '*' или '/'")
            let rhs = try parseLogicBlock(squareBracketDepth: squareBracketDepth)
            expression = BinaryExpression(lhs: expression, operator: multiplicativeOperator, rhs: rhs)
        }
        
        if check(.newLine) || check(.keywordEnd) || isEmpty() {
            if tokens[current - 1].type == .multiplicativeOperators {
                throw SyntaxError(description: "После оператора должно идти цифра или переменная", token: tokens[current - 1])
            }
        }
        
        return expression
    }
    
    private func parseLogicBlock(squareBracketDepth: Int = 0) throws -> Expression {
        var expression = try parseReverseLogicBlock(squareBracketDepth: squareBracketDepth)
        while check(.logicOperators) {
            let logicOperator = try expect(.logicOperators, errorDescription: "Ожидается логические операторы '&&' (И) или '||' (ИЛИ)")
            let rhs = try parseReverseLogicBlock()
            expression = BinaryExpression(lhs: expression, operator: logicOperator, rhs: rhs)
        }
        
        if check(.newLine) || check(.keywordEnd) || isEmpty() {
            if tokens[current - 1].type == .logicOperators {
                throw SyntaxError(description: "После оператора должно идти цифра или переменная", token: tokens[current - 1])
            }
        }
        
        return expression
    }
    
    private func parseReverseLogicBlock(squareBracketDepth: Int = 0) throws -> Expression {
        var logicOperator: Token? = nil
        
        if check(.reverseLogicOperator) {
            logicOperator = try expect(.reverseLogicOperator, errorDescription: "Ожидается логические оператор '!' (НЕ)")
        }
        
        let inner = try parseParticle(squareBracketDepth: squareBracketDepth)
        
        if let logicOperator = logicOperator {
            return UnaryExpression(operator: logicOperator, innerExpression: inner)
        }
        
        return inner
    }
    
    private func parseParticle(squareBracketDepth: Int = 0) throws -> Expression {
        if peek().type == .additiveOperators || peek().type == .multiplicativeOperators || peek().type == .logicOperators || peek().type == .reverseLogicOperator {
            throw SyntaxError(description: "Две операции не могут стоять подряд", token: peek())
        }

        switch peek().type {
            case .identifier:
                advance()
                return Identifier(value: tokens[current - 1])
            case .integer:
                advance()
                return Integer(value: Int(tokens[current - 1].string) ?? 0)
            case .openParenthesis:
                advance()
                let expression = try parseAdditionBlock(squareBracketDepth: squareBracketDepth)
                try expect(.closeParenthesis, errorDescription: "Ожидается закрывающая круглая скобка")
                if check(.closeSquareBracket) || check(.closeParenthesis) {
                    throw SyntaxError(description: "Лишняя закрывающая скобка", token: peek())
                }
                if check(.openParenthesis) || check(.openSquareBracket) {
                    throw SyntaxError(description: "Лишняя открывающая скобка", token: peek())
                }
                return expression
            case .openSquareBracket:
                if squareBracketDepth >= 2 || check(.closeSquareBracket){
                    throw SyntaxError(description: "Глубина вложенности квадратных скобок не может превышать 2", token: peek())
                }
                advance()
                let expression = try parseAdditionBlock(squareBracketDepth: squareBracketDepth + 1)
                try expect(.closeSquareBracket, errorDescription: "Ожидается закрывающая квадратная скобка")
                
                if check(.closeSquareBracket) || check(.closeParenthesis) {
                    throw SyntaxError(description: "Лишняя закрывающая скобка", token: peek())
                }
                
                if check(.openParenthesis) || check(.openSquareBracket) {
                    throw SyntaxError(description: "Лишняя открывающая скобка", token: peek())
                }
                return expression
            default:
                throw SyntaxError(description: "После оператора должны быть переменные или числа. Некорректное выражение.", token: peek())
        }
    }

    
    private func check(_ type: TokenType) -> Bool {
        if isEmpty() {
            return false
        }
        
        return peek().type == type
    }
    
    private func advance() {
        if !isEmpty() {
            current += 1
        }
    }
    
    private func isEmpty() -> Bool {
        return current >= tokens.count
    }
    
    private func peek() -> Token {
        return tokens[current]
    }
    
    private func expect(_ type: TokenType, errorDescription: String) throws -> Token {
        if check(type) {
            advance()
            return tokens[current - 1]
        } else {
            throw SyntaxError(description: errorDescription, token: peek())
        }
    }
    
    private func skipNewLine() {
        while peek().type == .newLine {
            current += 1
        }
    }
    
    private func expectNewStatement(_ errorDescription: String) throws {
        if peek().type != .newLine {
            throw SyntaxError(description: errorDescription, token: peek())
        } else {
            skipNewLine()
        }
    }
}
