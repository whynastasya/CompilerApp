//
//  AstTypes.swift
//  Compiler
//
//  Created by nastasya on 30.04.2024.
//

import Foundation

enum NodeType {
    case program
    case links
    case singleLink
    case word
    case binaryExpression
    case unaryExpression
    case identifier
    case integer
}

protocol Statement {
    var nodeType: NodeType { get }
}

protocol Expression: Statement { }

struct Program: Statement {
    let nodeType: NodeType = .program
    var body: [Statement]
}

struct Links: Statement {
    let nodeType: NodeType = .links
    var body: [SingleLink]
}

struct SingleLink: Statement {
    let nodeType: NodeType = .singleLink
    var body: [Word]
}

struct Word: Statement {
    let nodeType: NodeType = .word
    var identifier: Token
    var rhs: Expression
}

struct BinaryExpression: Expression {
    let nodeType: NodeType = .binaryExpression
    var lhs: Expression
    var `operator`: Token
    var rhs: Expression
}

struct UnaryExpression: Expression {
    let nodeType: NodeType = .unaryExpression
    var `operator`: Token
    var innerExpression: Expression
}

struct Identifier: Expression {
    let nodeType: NodeType = .identifier
    var value: Token
}

struct Integer: Expression {
    let nodeType: NodeType = .integer
    var value: Int
}
