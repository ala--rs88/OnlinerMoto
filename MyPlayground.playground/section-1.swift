// Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"

class A
{
    var s: String?
    
    var m: String!
    
    init()
    {
        self.m = "M"
    }
    
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


var i: Int!
if let x:String = a.SC
{
    i = 1
}
else
{
    i = 2
}

i


var aaa: A? = A()
aaa = nil

-1 > aaa?.c

var test = [1, 2, 3, 4, 5]
var s = 2
var n = 3
var test2 = test[s...s+n-1]