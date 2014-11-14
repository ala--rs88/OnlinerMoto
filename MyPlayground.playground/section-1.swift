// Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"

class A
{
    var s: String?
    
    let c = 5
    var SC: String? = "XXX"
    
    func doWork(a: A) {
        println("QQA");
    }
    
    private func doXXX() -> String
    {
        return "A doXXX"
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

a.SC = nil
a.SC == "XXX"