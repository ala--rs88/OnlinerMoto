// Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"

class A
{
    var s: String?
    
    let c = 5
    
    func doWork(a: A) {
        println("QQA");
    }
    
    private func doXXX() -> String
    {
        return "A doXXX"
    }
    
    private func doAAA(array:[String], s?: String) -> String
    {
        if (array.isEmpty)
        {
            return "Empty"
        }
        else
        {
            return "Full"
        }
    }
}

class B : A
{
    func doYYY() -> String
    {
        return super.doXXX() + self.doXXX()
    }
}

var a = A()
var b = B()

a.doXXX()
b.doXXX()
b.doYYY()
var x: [String] = nil

a.doAAA(["X", "Y"], s: "")
a.doAAA([], s: nil)
