//
//  ContentView.swift
//  Compiler
//
//  Created by nastasya on 27.04.2024.
//

import SwiftUI
import TextEditorPlus

struct ContentView: View {
    @State var text = input
    @State var result = "Результат работы:"
    @State var range = NSRange(location: 0, length: 0)
    
    var body: some View {
        HStack {
            VStack {
                Text("Исходный код")
                    .font(.title)
                    .foregroundStyle(.purple)
                TextEditorPlus(text: $text)
                    .textViewAttributedString(action: { val in
                        val.addAttribute(.backgroundColor, value: NSColor.red, range: range)
                        return val
                    })
                    .frame(minWidth: 500, minHeight: 500)
                    .border(.black)
                    .onChange(of: text) {
                        range = NSRange(location: 0, length: 0)
                    }
                
                Button("Выполнить") {
                    compile()
                }
                
                Text(result)
                    .frame(minWidth: 500, minHeight: 100)
                    .border(.black)
                    .font(.title2)
            }
            .padding()
            
            VStack {
                Text("БНФ языка")
                    .font(.title)
                    .foregroundStyle(.purple)
                Text(bnf)
                    .frame(minWidth: 500, minHeight: 500)
                    .font(.title3)
                    .border(.black)
                Spacer()
            }
            .padding()
        }
        .padding()
    }
    
    private func compile() {
        
        let lexer = Lexer(sourceCode: text)
        var tokens = [Token]()
        do {
            tokens = try lexer.tokenize()
            let parser = Parser(tokens: tokens)
            let program = try parser.parseProgram()
            let interpreter = Interpreter()
            result = try interpreter.interpret(program)
        } catch {
            if let error = error as? SyntaxError {
                result = "Ошибка: \(error.description)"
                print(error.description, error.token)
                range = NSRange(location: error.token.from, length: error.token.to - error.token.from + 1)
                DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: {
                    range = NSRange(location: 0, length: 0)
                })
            }
        }
    }
}
