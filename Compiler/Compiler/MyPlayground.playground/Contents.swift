import AppKit

var a: NSView? = NSView()
a = NSTextView()



class Foo<T> where T : Bar {}
class Bar {}
class BarChild : Bar {}

let array: Array<Bar> = Array<BarChild>()
//let instance: Foo<Bar> = Foo<BarChild>()

enum Opt<T> where T: Bar {
    case none
    case some(T)
}

var b: Opt<Bar> = .some(BarChild())

//b =

import UIKit

enum Opt<T> {
    case some (T)
    case none
}


var b = Optional.some(UIView())
let c = Optional.some(UILabel())
b = c


var m = Opt.some(UIView())
let a = Opt.some(UILabel())
m = a
