/*:
 # Day 1
 Variables, constants, strings, integers, and decimal numbers.
 */


var greeting = "Hello, playground"
print (greeting)
var myVariable = 42
myVariable = 50
let myConstant = 42
print ("1+2")

//variables
var name = "Ted"
let character = "Daphne"
var playerName = "Roy"
print(playerName)

playerName = "Dani"
print(playerName)

playerName = "Sam"
print(playerName)

let managerName = "Michael Scott"
let dogBreed = "Samoyed"
let meaningOfLife = "How many roads must a man walk down?"

//strings
let actor = "Denzel Washington"
let filename = "paris.jpg"
let result = "⭐️ You win! ⭐️"
let quote = "Then he tapped a sign saying \"Believe\" and walked away."
let movie = """
A day in
the life of an
Apple engineer
"""

print(movie)

print(actor.count)

let nameLength = actor.count
print(nameLength)

print(result.uppercased())

print(movie.hasPrefix("A day"))

print(filename.hasSuffix(".jpg"))

//integers
let score = 10
let reallyBig = 100000000
let lowerScore = score - 2
let higherScore = score + 10
let doubledScore = score * 2
let squaredScore = score * score
let halvedScore = score / 2
print(score)

var counter = 10
counter = counter + 5
counter += 5
print(counter)
counter *= 2
print(counter)
counter -= 10
print(counter)
counter /= 2
print(counter)

let number = 120
print(number.isMultiple(of: 3))
print(120.isMultiple(of: 3))

//decimal numbers, floating-point numbers
let number1 = 0.1 + 0.2 //double-precision floating-point number
print(number1)

let a = 1 //int
let b = 2.0 //double
//could do let c = a + Int(b) OR
let c = Double(a) + b

let double1 = 3.1
let double2 = 3131.3131
let double3 = 3.0
let int1 = 3

var name1 = "Nicolas Cage"
name1 = "John Travolta"
//name1 = 57 is not allowed since it is not a string

var rating = 5.0
rating *= 2

//: [Next](@next)
