//
//  Interperator.swift
//  Compiler
//
//  Created by nastasya on 06.05.2024.
//

import Foundation

final class Interpreter {
    func interpret(_ program: Program) throws -> String {
        var result = ""
        for link in program.body {
            let links = try interpretLinks(link as! Links)
            result += links + "\n"
        }
        
        return result
    }
    
    private func interpretLinks(_ links: Links) throws -> String {
        var result = ""
        for link in links.body {
            let link = try interpretSingleLink(link)
            result += link + "\n"
        }
        
        return result
    }
    
    private func interpretSingleLink(_ singleLink: SingleLink) throws -> String {
        var words = ""
        for word in singleLink.body {
            let word = try interpretWord(word)
            words += word + "\n"
        }
        return words
    }
    
    private func interpretWord(_ word: Word) throws -> String {
        let identifier = word.identifier.string
        let value = try evaluateExpression(word.rhs)
        
        return ("\(identifier) = \(value)")
    }
    
    private func evaluateExpression(_ expression: Expression) throws -> Any {
            switch expression.nodeType {
            case .integer:
                return (expression as! Integer).value
            case .identifier:
                let name = (expression as! Identifier).value.string
                return name
            case .binaryExpression:
                let binary = expression as! BinaryExpression
                let lhs = try evaluateExpression(binary.lhs)
                let rhs = try evaluateExpression(binary.rhs)
                switch binary.operator.type {
                case .additiveOperators:
                    if binary.operator.string == "+" {
                        if let lhsInt = lhs as? Int, let rhsInt = rhs as? Int {
                            return lhsInt + rhsInt
                        } else {
                            return "\(lhs) + \(rhs)"
                        }
                    } else if binary.operator.string == "-" {
                        if let lhsInt = lhs as? Int, let rhsInt = rhs as? Int {
                            return lhsInt - rhsInt
                        } else {
                            return "\(lhs) - \(rhs)"
                        }
                    }
                case .multiplicativeOperators:
                    if binary.operator.string == "*" {
                        if let lhsInt = lhs as? Int, let rhsInt = rhs as? Int {
                            return lhsInt * rhsInt
                        } else {
                            return "\(lhs) * \(rhs)"
                        }
                    } else if binary.operator.string == "/" {
                        if let lhsInt = lhs as? Int, let rhsInt = rhs as? Int {
                            return lhsInt / rhsInt
                        } else {
                            return "\(lhs) / \(rhs)"
                        }
                    }
                case .logicOperators:
                    if binary.operator.string == "&&" {
                        if let lhsInt = lhs as? Int, let rhsInt = rhs as? Int {
                            return ((lhsInt != 0 && rhsInt != 0) ? 1 : 0)
                        } else {
                            return "\(lhs) && \(rhs)"
                        }
                    } else if binary.operator.string == "||" {
                        if let lhsInt = lhs as? Int, let rhsInt = rhs as? Int {
                            return ((lhsInt != 0 || rhsInt != 0) ? 1 : 0)
                        } else {
                            return "\(lhs) || \(rhs)"
                        }
                    }
                default:
                        return ""
                }
            case .unaryExpression:
                let unary = expression as! UnaryExpression
                let value = try evaluateExpression(unary.innerExpression)
                if unary.operator.string == "-" {
                    return -(value as! Int)
                } else if unary.operator.string == "!" {
                    if let valueInt = value as? Int {
                        return valueInt == 0 ? 1 : 0
                    } else {
                        return "!\(value)"
                    }
                }
            default:
                    return ""
            }
            return ""
        }
    }
